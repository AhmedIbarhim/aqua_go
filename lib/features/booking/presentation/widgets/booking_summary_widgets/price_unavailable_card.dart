import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';

/// What the payment summary shows when the price call FAILED — in place of the
/// shimmer that used to sit there forever.
///
/// The summary's price arrives from a single call fired once, from
/// `booking_summary_view`'s `initState` post-frame callback: `/quote` on the
/// service flow, the wash-charge preview on the package flow. Nothing re-fires
/// it, and the snackbar that announced the failure is transient — so a customer
/// who looked away was left holding a shimmer that promised a price which was
/// never arriving, next to a Confirm button disabled for a reason nothing on
/// screen stated. The only way forward was to leave the flow and re-enter it.
///
/// This is the way forward, in place: it says what happened, it persists, and
/// its Retry re-fires the price call THIS flow prices from (the view routes
/// that — see `_fetchPrice`). It deliberately mirrors `ServicesLoadErrorWidget`,
/// the same affordance the bundled-service picker offers one screen earlier,
/// so the two failures read as one pattern.
///
/// It states NO figure. The rule the price gate rests on is unchanged: never
/// show a number that did not come from the server (`booking_payable_total.dart`
/// — a placeholder honours it, a fabricated SAR 0.00 does not), and Confirm
/// stays disabled here exactly as it is while the call is in flight.
class PriceUnavailableCard extends StatelessWidget {
  const PriceUnavailableCard({super.key, required this.onRetry});

  /// Re-fires this flow's price call. Owned by the summary view, which is what
  /// knows which of the two calls the flow prices from.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                size: 20,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 8),
              // The message takes the remaining width and wraps, rather than
              // being clipped: Arabic renders this copy appreciably longer than
              // English, and an unbounded Text inside a Row overflows.
              Expanded(
                child: Text(
                  LocaleKeys.bookings_price_unavailable.tr(context: context),
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Direction-agnostic: `centerEnd` puts the action on the right in
          // English and the left in Arabic with no branching.
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: const ValueKey('price-retry'),
              onPressed: onRetry,
              child: Text(
                LocaleKeys.retry.tr(context: context),
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
