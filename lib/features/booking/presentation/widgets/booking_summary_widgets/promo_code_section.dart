import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../generated/locale_keys.g.dart';

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

  @override
  Widget build(BuildContext context) {
    final hasAppliedCode = appliedPromoCode != null;
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
        if (!hasAppliedCode)
          GestureDetector(
            onTap: () => _showPromoCodeDialog(context),
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
                  Text(
                    LocaleKeys.bookings_apply_promo_code.tr(context: context),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.defaultSubtle,
                    border: Border.all(
                      color: context.colors.borderSecondary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: context.colors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                // The label column takes the room the remove button leaves and
                // ellipsises: an unbounded Column beside a Spacer overflowed the
                // row as soon as the promo code was long.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${LocaleKeys.bookings_promo_code_title.tr(context: context)} $appliedPromoCode',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium14.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleKeys.bookings_promo_code_applied.tr(
                          context: context,
                        ),
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
                  onTap: onRemovePromoCode,
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
                          LocaleKeys.bookings_delete_promo_code.tr(
                            context: context,
                          ),
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

/// Owns the field controller for the life of the dialog route so it is disposed
/// with it. Built inside `showDialog`'s builder, a controller is never disposed
/// — the dialog is closed by popping the route, not by anything that could call
/// `dispose` on a local.
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

  // Apply stays enabled and no-ops on empty input, as before: gating it on the
  // field's contents breaks fill-then-click test fixtures, which tap without
  // pumping a frame in between.
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
              hintText: LocaleKeys.bookings_apply_code_hint.tr(
                context: context,
              ),
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
