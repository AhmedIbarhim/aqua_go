// App Check: the Dio interceptor attaches X-Firebase-AppCheck best-effort and
// never blocks a request when the token is null or the fetch throws.
import 'package:aqua_go/core/config/networking/app_check_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAppCheck implements FirebaseAppCheck {
  _FakeAppCheck({this.token, this.throwOnGet = false});
  final String? token;
  final bool throwOnGet;

  @override
  Future<String?> getToken([bool? forceRefresh]) async {
    if (throwOnGet) throw Exception('attestation unavailable');
    return token;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

Future<RequestOptions> _run(AppCheckInterceptor interceptor) async {
  final options = RequestOptions(path: '/api/customer/login/otp');
  final handler = RequestInterceptorHandler();
  await interceptor.onRequest(options, handler);
  return options;
}

void main() {
  test('attaches X-Firebase-AppCheck when a token is available', () async {
    final options = await _run(
      AppCheckInterceptor(appCheck: _FakeAppCheck(token: 'attest-token')),
    );
    expect(options.headers['X-Firebase-AppCheck'], 'attest-token');
  });

  test('adds no header when the token is null', () async {
    final options = await _run(
      AppCheckInterceptor(appCheck: _FakeAppCheck(token: null)),
    );
    expect(options.headers.containsKey('X-Firebase-AppCheck'), isFalse);
  });

  test('passes through untouched when token fetch throws', () async {
    final options = await _run(
      AppCheckInterceptor(appCheck: _FakeAppCheck(throwOnGet: true)),
    );
    expect(options.headers.containsKey('X-Firebase-AppCheck'), isFalse);
  });
}
