import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../generated/locale_keys.g.dart';

class PromoCodeSection extends StatelessWidget {
  final String? appliedPromoCode;
  final Function(String) onApplyPromoCode;
  final VoidCallback onRemovePromoCode;

  const PromoCodeSection({
    super.key,
    required this.appliedPromoCode,
    required this.onApplyPromoCode,
    required this.onRemovePromoCode,
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
                    onRemove: onRemovePromoCode,
                  ),
          ),
        ),
      ],
    );
  }

  void _showPromoCodeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _PromoCodeDialog(onApply: onApplyPromoCode),
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
    required this.onRemove,
  });

  final String code;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
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
          // Lands a beat after the card itself, so the tick reads as the
          // confirmation rather than more of the same fade.
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
                  LocaleKeys.bookings_promo_code_applied.tr(context: context),
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

class _CheckMark extends StatelessWidget {
  const _CheckMark();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 520),
      curve: const Interval(0.45, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.defaultSubtle,
          border: Border.all(
            color: context.colors.borderSecondary.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(Icons.check, color: context.colors.primary, size: 16),
      ),
    );
  }
}

/// Owns the field controller for the life of the dialog so it is disposed with
/// the route, and keeps the Apply action disabled until there is something to
/// apply.
class _PromoCodeDialog extends StatefulWidget {
  const _PromoCodeDialog({required this.onApply});

  final ValueChanged<String> onApply;

  @override
  State<_PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<_PromoCodeDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    Navigator.of(context).pop();
    widget.onApply(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.cardBackGround,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        LocaleKeys.bookings_apply_promo_code.tr(context: context),
        style: AppTextStyles.bold16.copyWith(color: context.colors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: LocaleKeys.bookings_apply_code_hint.tr(context: context),
              hintStyle: AppTextStyles.regular14.copyWith(
                color: context.colors.textTertiary,
              ),
              filled: true,
              fillColor: context.colors.fields,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.borderSecondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.primary),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            LocaleKeys.bookings_cancel.tr(context: context),
            style: AppTextStyles.medium14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            LocaleKeys.bookings_apply.tr(context: context),
            style: AppTextStyles.medium14.copyWith(
              color: context.colors.textTheme,
            ),
          ),
        ),
      ],
    );
  }
}
