package sa.aquago.customerapp

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

/**
 * `aquago/receipts` — the app's first platform channel. One method,
 * `saveAndReveal(bytes, filename, mimeType)`, backed by hand-written native
 * code because no maintained Flutter plugin covers "insert a file into the
 * MediaStore Downloads collection" (Android) without the caveats the owner
 * ruled out (media_store_plus / flutter_media_store / file_save_directory —
 * see the brief this shipped against).
 */
class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "aquago/receipts"
        private const val WRITE_STORAGE_REQUEST_CODE = 4201
    }

    /**
     * Holds the in-flight save across the WRITE_EXTERNAL_STORAGE permission
     * round trip on API 24-28 — [ActivityCompat.requestPermissions] is
     * asynchronous, and the grant/denial only arrives via
     * [onRequestPermissionsResult], which cannot itself return a value to
     * the original [MethodChannel.Result]. Null outside that window.
     */
    private var pendingSave: PendingSave? = null

    private class PendingSave(
        val result: MethodChannel.Result,
        val bytes: ByteArray,
        val filename: String,
        val mimeType: String,
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "saveAndReveal") {
            result.notImplemented()
            return
        }

        val bytes = call.argument<ByteArray>("bytes")
        val filename = call.argument<String>("filename")
        val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
        if (bytes == null || filename == null) {
            result.error("bad_args", "bytes/filename missing", null)
            return
        }

        saveAndReveal(bytes, filename, mimeType, result)
    }

    private fun saveAndReveal(
        bytes: ByteArray,
        filename: String,
        mimeType: String,
        result: MethodChannel.Result,
    ) {
        // API 29+ (scoped storage): no permission needed, MediaStore owns
        // the Downloads collection.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveViaMediaStore(bytes, filename, mimeType, result)
            return
        }

        // API 24-28 predates scoped storage and MediaStore.Downloads (added
        // in Q): write straight into the public Downloads directory, which
        // needs the legacy runtime permission first.
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            == PackageManager.PERMISSION_GRANTED
        ) {
            saveToLegacyDownloads(bytes, filename, result)
            return
        }

        pendingSave = PendingSave(result, bytes, filename, mimeType)
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
            WRITE_STORAGE_REQUEST_CODE,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != WRITE_STORAGE_REQUEST_CODE) return

        val pending = pendingSave ?: return
        pendingSave = null

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            // Typed, non-throwing failure — the Dart side (ReceiptFilesChannel)
            // localises this itself rather than catching a raw
            // PlatformException.
            pending.result.success(mapOf("ok" to false, "reason" to "permission_denied"))
            return
        }

        saveToLegacyDownloads(pending.bytes, pending.filename, pending.result)
    }

    /** API 24-28: pre-scoped-storage public Downloads directory. */
    private fun saveToLegacyDownloads(
        bytes: ByteArray,
        filename: String,
        result: MethodChannel.Result,
    ) {
        try {
            @Suppress("DEPRECATION")
            val downloadsDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) downloadsDir.mkdirs()
            val file = File(downloadsDir, filename)
            FileOutputStream(file).use { it.write(bytes) }
            result.success(mapOf("ok" to true))
        } catch (e: IOException) {
            result.error("write_failed", e.message, null)
        }
    }

    /** API 29+: MediaStore Downloads collection, no permission required. */
    private fun saveViaMediaStore(
        bytes: ByteArray,
        filename: String,
        mimeType: String,
        result: MethodChannel.Result,
    ) {
        try {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, filename)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }

            val resolver = applicationContext.contentResolver
            val uri: Uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("MediaStore insert returned no uri")

            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IOException("Could not open output stream for $uri")

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)

            result.success(mapOf("ok" to true))
        } catch (e: IOException) {
            result.error("write_failed", e.message, null)
        }
    }
}
