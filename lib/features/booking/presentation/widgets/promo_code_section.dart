import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_text_field.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../domain/promo_code_history.dart';
import '../../domain/promo_code_rules.dart';

/// UCC16's promo affordance: apply a code, see what it saved, take it off
/// again.
///
/// **There is deliberately no "N uses remaining" line**, though UCC16's UI/UX
/// notes ask for one. No customer-facing endpoint carries that number:
/// `GET /api/customer/promos/{code}` returns `PromoTerms`
/// (code / discountType / value / minOrderMinor / validFrom / validTo), the
/// quote response carries `promoCode` + `promoDiscountMinor`, and the offer
/// feed's terms carry neither. `remainingUses` exists only on the ADMIN
/// projection, withheld from every customer surface on purpose — remaining
/// campaign inventory on an anonymous endpoint is a "which campaigns are nearly
/// exhausted" scraper. Do not add a field to the customer contract to satisfy
/// this note; it is an owner decision, not an oversight.
class PromoCodeSection extends StatelessWidget {
  final String? appliedPromoCode;

  /// What the applied code took off this order, in halala. Rendered as the
  /// amount saved: a customer who is only told "code applied" cannot tell
  /// whether it was worth 5 SAR or 50.
  final int promoDiscountMinor;

  final Function(String) onApplyPromoCode;
  final VoidCallback onRemovePromoCode;

  const PromoCodeSection({
    super.key,
    required this.appliedPromoCode,
    required this.onApplyPromoCode,
    required this.onRemovePromoCode,
    this.promoDiscountMinor = 0,
  });

  static const Duration _swap = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final code = appliedPromoCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_promo_code_title.tr(context: context),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Applying or clearing a code swaps one box for a taller one. The size
        // animation carries the surrounding summary through that change instead
        // of letting the payment totals below jump.
        AnimatedSize(
          duration: _swap,
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: _swap,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: code == null
                ? _ApplyPrompt(
                    key: const ValueKey('promo-empty'),
                    onTap: () => _showPromoCodeDialog(context),
                  )
                : _AppliedCode(
                    key: const ValueKey('promo-applied'),
                    code: code,
                    discountMinor: promoDiscountMinor,
                    onRemove: onRemovePromoCode,
                  ),
          ),
        ),
      ],
    );
  }

  /// Hosted in the app's own alert box — blurred backdrop, 24pt radius,
  /// `CustomButton` actions — which is what every other dialog in the product
  /// uses (`booking_location_view`, the delete confirmations, the success
  /// boxes). A Material `AlertDialog` here was the only one in the app.
  void _showPromoCodeDialog(BuildContext context) {
    context.showCustomAlert<void>(
      child: _PromoCodeDialog(onApply: onApplyPromoCode),
    );
  }
}

class _ApplyPrompt extends StatelessWidget {
  const _ApplyPrompt({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.warning, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.discount_outlined, color: context.colors.warning),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                LocaleKeys.bookings_apply_promo_code.tr(context: context),
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppliedCode extends StatelessWidget {
  const _AppliedCode({
    super.key,
    required this.code,
    required this.discountMinor,
    required this.onRemove,
  });

  final String code;
  final int discountMinor;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // What the code was worth on THIS order, taken from the locked quote. Falls
    // back to the plain "applied" line for the zero-discount case (a code that
    // priced to nothing on this basket), where naming a saving would be a lie.
    final saved = discountMinor > 0
        ? LocaleKeys.bookings_promo_saved.tr(
            context: context,
            args: [(discountMinor / 100).toStringAsFixed(2)],
          )
        : LocaleKeys.bookings_promo_code_applied.tr(context: context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.themeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.borderSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const _CheckMark(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${LocaleKeys.bookings_promo_code_title.tr(context: context)} $code',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium14.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  saved,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: context.colors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    LocaleKeys.bookings_delete_promo_code.tr(context: context),
                    style: AppTextStyles.medium12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The applied-code tick. Static, like every other status glyph in the product
/// — the surrounding `AnimatedSwitcher`/`AnimatedSize` already carries the swap
/// from the empty prompt to this card.
class _CheckMark extends StatelessWidget {
  const _CheckMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.defaultSubtle,
        border: Border.all(
          color: context.colors.borderSecondary.withValues(alpha: 0.5),
        ),
      ),
      child: Icon(Icons.check, color: context.colors.primary, size: 16),
    );
  }
}

/// Owns the field controller for the life of the dialog so it is disposed with
/// the route, keeps the Apply action disabled until the code has the shape the
/// server accepts, and offers the codes this device has used before.
class _PromoCodeDialog extends StatefulWidget {
  const _PromoCodeDialog({required this.onApply});

  final ValueChanged<String> onApply;

  @override
  State<_PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<_PromoCodeDialog> {
  final TextEditingController _controller = TextEditingController();

  /// Codes THIS customer applied before on this device, most recent first
  /// (UCC16 UI/UX). Scoped by account: a shared handset must not offer one
  /// person the codes another earned.
  late final List<String> _history = PromoCodeHistory.recent();

  /// Only judge the input once the customer has typed something: an empty field
  /// they have not filled in yet is not an error, it is the starting state.
  bool get _isEmpty => _controller.text.trim().isEmpty;
  bool get _isWellFormed => isWellFormedPromoCode(_controller.text);

  /// The history entries that still match what has been typed. Filtering by
  /// prefix is what makes this autocomplete rather than a static list.
  List<String> get _suggestions {
    final typed = _controller.text.trim().toUpperCase();
    if (typed.isEmpty) return _history;
    return _history
        .where((code) => code.startsWith(typed) && code != typed)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (!isWellFormedPromoCode(code)) {
      // Re-render so the malformed-code line is on screen; the customer may
      // have hit the keyboard's done action rather than the disabled button.
      setState(() {});
      return;
    }
    Navigator.of(context).pop();
    widget.onApply(code);
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final showsError = !_isEmpty && !_isWellFormed;
    final suggestions = _suggestions;
    // The content grew a malformed-code line and up to five suggestion chips on
    // top of the field. On a short screen with the keyboard up that is more than
    // the box can hold, and the customer would lose the Apply button off the
    // bottom. Scrolling costs nothing when it fits.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centred `medium16`, the same heading treatment `WarningBox` and
          // `SuccessAlertBox` give theirs — the form below it stays left-aligned
          // like every other form in the app.
          SizedBox(
            width: double.infinity,
            child: Text(
              LocaleKeys.bookings_apply_promo_code.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyles.medium16.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: width * 0.04),
          // The house field. `mustCapitalize` is exactly UCC16's input rule —
          // alphanumeric only, upper case — so a stray character or a pasted URL
          // never reaches the shape check at all.
          CustomTextField(
            label: LocaleKeys.bookings_promo_code_title.tr(context: context),
            hint: LocaleKeys.bookings_apply_code_hint.tr(context: context),
            controller: _controller,
            mustCapitalize: true,
            autofocus: true,
            textInputAction: TextInputAction.done,
            fillColor: context.colors.fields,
            // Re-renders the Apply button's enabled state, the malformed-code
            // line and the filtered suggestions. It never submits on its own —
            // applying stays an explicit action.
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          if (showsError) ...[
            const SizedBox(height: 8),
            Text(
              LocaleKeys.bookings_promo_code_malformed.tr(context: context),
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              LocaleKeys.bookings_promo_recent_codes.tr(context: context),
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final code in suggestions)
                  _SuggestionChip(
                    code: code,
                    onTap: () {
                      _controller.text = code;
                      _controller.selection = TextSelection.collapsed(
                        offset: code.length,
                      );
                      setState(() {});
                    },
                  ),
              ],
            ),
          ],
          SizedBox(height: width * 0.06),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  key: const ValueKey('promo-apply'),
                  enabled: _isWellFormed,
                  onPressed: _submit,
                  text: LocaleKeys.bookings_apply.tr(context: context),
                ),
              ),
              SizedBox(width: width * 0.02),
              Expanded(
                child: CustomButton(
                  key: const ValueKey('promo-cancel'),
                  text: LocaleKeys.bookings_cancel.tr(context: context),
                  color: context.colors.cardBackGround,
                  borderColor: context.colors.borderSecondary,
                  textColor: context.colors.textPrimary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One previously used code, tapped to fill the field. It fills rather than
/// applies: the customer stays in control of when the code is sent, and can
/// still edit it.
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.code, required this.onTap});

  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.fields,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.borderSecondary.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          code,
          style: AppTextStyles.medium12.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
