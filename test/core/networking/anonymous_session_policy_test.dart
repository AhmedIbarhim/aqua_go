import 'package:aqua_go/core/config/networking/anonymous_session_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the extra-key literal is the one the data source writes', () {
    expect(kAllowAnonymous, 'allowAnonymous');
  });

  group('shouldTearDownTokenlessSession', () {
    test('explicitly anonymous request never tears down, even on 401', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: true, statusCode: 401),
        isFalse,
      );
    });

    test('anonymous request is untouched by a 404', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: true, statusCode: 404),
        isFalse,
      );
    });

    test('offline / timeout (null status) never tears down', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: false, statusCode: null),
        isFalse,
      );
    });

    test('server error never tears down', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: false, statusCode: 503),
        isFalse,
      );
    });

    test('404 on a protected endpoint never tears down', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: false, statusCode: 404),
        isFalse,
      );
    });

    test('403 never tears down', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: false, statusCode: 403),
        isFalse,
      );
    });

    test('401 on a non-anonymous request is the only teardown trigger', () {
      expect(
        shouldTearDownTokenlessSession(allowAnonymous: false, statusCode: 401),
        isTrue,
      );
    });
  });
}
