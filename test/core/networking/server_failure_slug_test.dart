import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:flutter_test/flutter_test.dart';

/// The RFC 9457 `type` slug is the only machine-readable statement of WHICH
/// rejection the server raised. `message` is localized prose and `type` is a
/// coarse transport class, so neither can separate two rejections that share a
/// status code — and under pay-before-create some of those differ in whether
/// the money came back. This locks the extraction and the one decision that
/// rides on it.
Map<String, dynamic> _problem(String type) => {
      'type': 'https://api.aquago.sa/errors/$type',
      'title': 'Something',
      'detail': 'A localized sentence for the customer.',
      'status': 422,
    };

void main() {
  group('ServerFailure carries the error slug', () {
    test('reads the last path segment, whatever the host', () {
      expect(
        ServerFailure.fromResponse(409, {
          'type': 'https://qa-api.aquago.sa/errors/slot-no-longer-available',
          'detail': 'The slot is gone.',
        }).slug,
        'slot-no-longer-available',
      );
      expect(
        ServerFailure.fromResponse(409, {
          'type': 'https://api.aquago.sa/errors/slot-no-longer-available',
          'detail': 'The slot is gone.',
        }).slug,
        'slot-no-longer-available',
      );
    });

    test('a body with no usable type carries no slug', () {
      expect(ServerFailure.fromResponse(500, null).slug, isNull);
      expect(ServerFailure.fromResponse(422, {'detail': 'x'}).slug, isNull);
      expect(
        ServerFailure.fromResponse(422, {'type': 'about:blank'}).slug,
        isNull,
        reason: 'about:blank is the RFC default and names no rejection',
      );
    });

    test('the localized detail is still what the customer reads', () {
      final failure = ServerFailure.fromResponse(422, _problem('promo-code-no-longer-valid'));
      expect(failure.message, 'A localized sentence for the customer.');
      expect(failure.type, FailureType.validation);
    });
  });

  group('AQG-436 — the booking-edit promo-zone rejection', () {
    // The customer app has no booking-edit screen yet
    // (Endpoints.editBookingLogistics has zero callers), so there is no
    // per-defect client code to write. What there IS, is the generic
    // RFC 9457 path every rejection arrives through — and subplan 01's
    // typed rejection has to survive it intact: the Arabic sentence has to
    // reach the customer unchanged, and the slug has to stay
    // machine-readable so the edit screen, when it is built, can branch on
    // THIS rejection rather than on a status code it shares with dozens.
    //
    // Status is 400, not 422 (owner decision D18): the contracted slug
    // already exists on ErrorCode.PROMO_CODE_REJECTED_ZONE_NOT_ELIGIBLE at
    // BAD_REQUEST and is pinned there by two backend architecture tests.
    // fromResponse routes 400/422/409 into the same validation arm, so the
    // client sees no difference.
    //
    // The strings are the seeded bundle values (errors_ar.properties:488,
    // errors_en.properties:491 — the ICU `unknown` branch). The slug, the
    // status and the shape are subplan 01's contract. If this group ever
    // fails, the CLIENT renderer regressed — fix server_failure.dart or
    // re-agree the contract; do not relax the assertion.
    const arDetail =
        'هذا الرمز يسري فقط في مناطق محددة، والمنطقة التي اخترتها ليست منها.';
    const enDetail = 'This code applies only in certain areas, and the area '
        'you selected is not one of them.';

    Map<String, dynamic> promoZoneRejection() => {
          'type': 'https://api.aquago.sa/errors/promo-zone-not-eligible',
          'title': 'هذا الرمز لا ينطبق في المنطقة المختارة',
          'detail': arDetail,
          'status': 400,
        };

    test('the slug survives the transport intact', () {
      expect(ServerFailure.fromResponse(400, promoZoneRejection()).slug,
          'promo-zone-not-eligible');
    });

    test('the Arabic detail is what the customer reads, verbatim', () {
      final failure = ServerFailure.fromResponse(400, promoZoneRejection());
      expect(failure.message, arDetail);
      expect(failure.type, FailureType.validation);
    });

    test('the English detail is passed through the same way', () {
      final failure = ServerFailure.fromResponse(400, {
        'type': 'https://api.aquago.sa/errors/promo-zone-not-eligible',
        'title': 'This code does not apply in the selected area',
        'detail': enDetail,
        'status': 400,
      });
      expect(failure.slug, 'promo-zone-not-eligible');
      expect(failure.message, enDetail);
    });

    test('a promo-zone rejection is distinguishable from every other '
        'validation rejection', () {
      // The whole reason the slug exists: two rejections that share a
      // status code are otherwise the same object to calling code.
      final zone = ServerFailure.fromResponse(400, promoZoneRejection());
      final other = ServerFailure.fromResponse(400, {
        'type': 'https://api.aquago.sa/errors/promo-code-no-longer-valid',
        'detail': 'انتهت صلاحية كود الخصم.',
      });
      expect(zone.slug, isNot(other.slug));
      expect(zone.type, other.type,
          reason: 'both are FailureType.validation — only the slug separates them');
    });

    test('a host change does not stop the rejection being recognised', () {
      expect(
        ServerFailure.fromResponse(400, {
          'type': 'https://qa-api.aquago.sa/errors/promo-zone-not-eligible',
          'detail': arDetail,
        }).slug,
        'promo-zone-not-eligible',
      );
    });
  });
}
