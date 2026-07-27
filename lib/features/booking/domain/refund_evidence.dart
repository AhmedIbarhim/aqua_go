import '../../../core/config/networking/exceptions/failure.dart';

/// The server rejections that are also a statement that the money came back.
///
/// Under pay-before-create the card is charged on-device BEFORE the booking row
/// exists, so a failed create leaves money already taken. The backend
/// compensates on exactly the paths below — each one calls its
/// `autoRefundOnFailedCreate` before throwing, and the refund is part of the
/// contract those rejections carry, not an inference:
///
/// * `slot-no-longer-available` (409) — the slot was lost after the charge.
/// * `payment-verification-failed` (422) — the verified payment did not match
///   the quote (amount / currency / owner / quote binding).
/// * `promo-code-no-longer-valid` (422) — the promo cap was consumed between
///   the quote and the charge.
/// * `subscription-payment-verification-failed` (422) and
///   `subscription-allowance-concurrently-exhausted` (409) — the same two
///   shapes on the subscription / package-wash side.
///
/// Every OTHER outcome is indeterminate to the client and must not be told to
/// the customer as a refund. A transport failure never reached an answer at all
/// and the booking may in fact have been created; a 5xx rolled the transaction
/// back but ran no compensation; and several 4xx rejections on the create path
/// (zone mismatch, saved address gone, schedule window, duplicate booking) throw
/// AFTER the charge was verified without refunding at all.
///
/// **There is no sweeper behind those.** An earlier version of this doc said the
/// reconciliation job was the net for them. It is not: `MoyasarReconciliationJob`
/// sweeps `PENDING_PAYMENT` intents, and its orphan-refund arm ships disabled
/// and — even enabled — only logs; it never calls `paymentsGateway.refund`. So
/// the copy on this branch must not imply a refund is coming, and closing the
/// backend gap is a real fix, not a comment change.
const Set<String> refundEvidenceSlugs = {
  'slot-no-longer-available',
  'payment-verification-failed',
  'promo-code-no-longer-valid',
  'subscription-payment-verification-failed',
  'subscription-allowance-concurrently-exhausted',
};

/// True when [failure] is one of the rejections above — i.e. the client has the
/// server's own word that the charge was refunded, rather than a guess.
bool carriesRefundEvidence(Failure failure) =>
    failure is ServerFailure && refundEvidenceSlugs.contains(failure.slug);
