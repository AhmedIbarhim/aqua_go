import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../generated/locale_keys.g.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image using the camera.
  static Future<File?> pickWithCamera({bool withCropping = true}) async {
    return _pickImage(source: ImageSource.camera, withCropping: withCropping);
  }

  /// Picks an image from the gallery.
  static Future<File?> pickWithGallery({bool withCropping = true}) async {
    return _pickImage(source: ImageSource.gallery, withCropping: withCropping);
  }

  /// Shows a bottom sheet to pick an image from camera or gallery.
  static Future<File?> showImageSourceDialog(
    BuildContext context, {
    bool withCropping = true,
  }) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(LocaleKeys.take_photo.tr()),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(LocaleKeys.select_from_gallery.tr()),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (source != null) {
      return _pickImage(source: source, withCropping: withCropping);
    }
    return null;
  }

  static Future<File?> _pickImage({
    required ImageSource source,
    bool withCropping = true,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return null;

      final File imageFile = File(image.path);

      if (withCropping) {
        return await _cropImage(imageFile);
      }

      return imageFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: LocaleKeys.edit.tr(),
            toolbarColor: const Color(0xFF16F7FF),
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: LocaleKeys.edit.tr(),
            doneButtonTitle: LocaleKeys.ok.tr(),
            cancelButtonTitle: LocaleKeys.cancel.tr(),
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return imageFile;
    }
  }
}
