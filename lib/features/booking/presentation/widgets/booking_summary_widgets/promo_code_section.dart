import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/components/custom_button.dart';
import '../../../../../core/components/custom_text_field.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../domain/promo_code_history.dart';
import '../../../domain/promo_code_rules.dart';

class PromoCodeSection extends StatelessWidget {
  final String? appliedPromoCode;

  final int promoDiscountMinor;

  final Function(String) onApplyPromoCode;
  final VoidCallback onRemovePromoCode;

  final bool canReapplyOffer;

  final String? reapplyOfferTitle;
  final VoidCallback? onReapplyOffer;

  const PromoCodeSection({
    super.key,
    required this.appliedPromoCode,
    required this.onApplyPromoCode,
    required this.onRemovePromoCode,
    this.promoDiscountMinor = 0,
    this.canReapplyOffer = false,
    this.reapplyOfferTitle,
    this.onReapplyOffer,
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

        if (canReapplyOffer && onReapplyOffer != null) ...[
          const SizedBox(height: 12),
          _ReapplyOffer(
            key: const ValueKey('offer-reapply'),
            offerTitle: reapplyOfferTitle,
            onTap: onReapplyOffer!,
          ),
        ],
      ],
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class _ReapplyOffer extends StatelessWidget {
  const _ReapplyOffer({
    super.key,
    required this.offerTitle,
    required this.onTap,
  });

  final String? offerTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = offerTitle?.trim() ?? '';
    final label = title.isEmpty
        ? LocaleKeys.bookings_reapply_offer_generic.tr(context: context)
        : LocaleKeys.bookings_reapply_offer.tr(context: context, args: [title]);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.primary, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, color: context.colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _PromoCodeDialog extends StatefulWidget {
  const _PromoCodeDialog({required this.onApply});

  final ValueChanged<String> onApply;

  @override
  State<_PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<_PromoCodeDialog> {
  final TextEditingController _controller = TextEditingController();

  late final List<String> _history = PromoCodeHistory.recent();

  bool get _isEmpty => _controller.text.trim().isEmpty;
  bool get _isWellFormed => isWellFormedPromoCode(_controller.text);

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

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          CustomTextField(
            label: LocaleKeys.bookings_promo_code_title.tr(context: context),
            hint: LocaleKeys.bookings_apply_code_hint.tr(context: context),
            controller: _controller,
            mustCapitalize: true,
            autofocus: true,
            textInputAction: TextInputAction.done,
            fillColor: context.colors.fields,

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
