import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/booking/domain/refund_evidence.dart';
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

  group('refund evidence', () {
    test('the rejections that run the compensating refund carry it', () {
      for (final slug in refundEvidenceSlugs) {
        expect(
          carriesRefundEvidence(ServerFailure.fromResponse(422, _problem(slug))),
          isTrue,
          reason: '$slug refunds the charge before it throws',
        );
      }
    });

    test('a 4xx on a path with no compensation does NOT', () {
      // Same 422 shape, thrown after the payment was verified, with no refund
      // run — and NOTHING behind the client runs one either. There is no
      // sweeper to defer to: MoyasarReconciliationJob's orphan-refund arm ships
      // disabled, only logs when enabled, and sweeps PENDING_PAYMENT rather
      // than these. So the charge really does stay where it is, and the client
      // must not claim otherwise.
      for (final slug in ['zone-mismatch', 'address-outside-service-area',
          'saved-address-not-found', 'invalid-booking-creation-request']) {
        expect(
          carriesRefundEvidence(ServerFailure.fromResponse(422, _problem(slug))),
          isFalse,
          reason: '$slug leaves the charge where it is',
        );
      }
    });

    test('a transport failure never does — no answer, no evidence', () {
      expect(
        carriesRefundEvidence(
          const ServerFailure('No internet connection', type: FailureType.network),
        ),
        isFalse,
      );
      expect(
        carriesRefundEvidence(
          const ServerFailure('Connection timed out', type: FailureType.timeout),
        ),
        isFalse,
      );
      expect(carriesRefundEvidence(ServerFailure.fromResponse(502, null)), isFalse);
    });
  });
}
