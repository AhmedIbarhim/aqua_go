// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import '../../../../../core/themes/app_text_styles.dart';
// import '../../../../../core/extentions/context_extentions.dart';
// import '../../../../../generated/locale_keys.g.dart';

// class PromoCodeSection extends StatelessWidget {
//   final String? appliedPromoCode;
//   final Function(String) onApplyPromoCode;
//   final VoidCallback onRemovePromoCode;

//   const PromoCodeSection({
//     super.key,
//     required this.appliedPromoCode,
//     required this.onApplyPromoCode,
//     required this.onRemovePromoCode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasAppliedCode = appliedPromoCode != null;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           LocaleKeys.bookings_promo_code_title.tr(context: context),
//           style: AppTextStyles.regular16.copyWith(
//             color: context.colors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         if (!hasAppliedCode)
//           GestureDetector(
//             onTap: () => _showPromoCodeDialog(context),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: context.colors.themeColor,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: context.colors.warning, width: 1),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.discount_outlined, color: context.colors.warning),
//                   const SizedBox(width: 8),
//                   Text(
//                     LocaleKeys.bookings_apply_promo_code.tr(context: context),
//                     style: AppTextStyles.medium14.copyWith(
//                       color: context.colors.warning,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         else
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: context.colors.themeColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: context.colors.borderSecondary.withValues(alpha: 0.3),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: context.colors.defaultSubtle,
//                     border: Border.all(
//                       color: context.colors.borderSecondary.withValues(
//                         alpha: 0.5,
//                       ),
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.check,
//                     color: context.colors.primary,
//                     size: 16,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${LocaleKeys.bookings_promo_code_title.tr(context: context)} $appliedPromoCode',
//                       style: AppTextStyles.medium14.copyWith(
//                         color: context.colors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       LocaleKeys.bookings_promo_code_applied.tr(
//                         context: context,
//                       ),
//                       style: AppTextStyles.regular12.copyWith(
//                         color: context.colors.textTertiary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: onRemovePromoCode,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: context.colors.error,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.close, color: Colors.white, size: 14),
//                         const SizedBox(width: 4),
//                         Text(
//                           LocaleKeys.bookings_delete_promo_code.tr(
//                             context: context,
//                           ),
//                           style: AppTextStyles.medium12.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   void _showPromoCodeDialog(BuildContext context) {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: context.colors.cardBackGround,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             LocaleKeys.bookings_apply_promo_code.tr(context: context),
//             style: AppTextStyles.bold16.copyWith(
//               color: context.colors.textPrimary,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: controller,
//                 autofocus: true,
//                 style: AppTextStyles.regular14.copyWith(
//                   color: context.colors.textPrimary,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: LocaleKeys.bookings_apply_code_hint.tr(
//                     context: context,
//                   ),
//                   hintStyle: AppTextStyles.regular14.copyWith(
//                     color: context.colors.textTertiary,
//                   ),
//                   filled: true,
//                   fillColor: context.colors.fields,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: context.colors.borderSecondary,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: context.colors.primary),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(
//                 LocaleKeys.bookings_cancel.tr(context: context),
//                 style: AppTextStyles.medium14.copyWith(
//                   color: context.colors.textSecondary,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final code = controller.text.trim();
//                 if (code.isNotEmpty) {
//                   Navigator.of(dialogContext).pop();
//                   onApplyPromoCode(code);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: context.colors.primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 LocaleKeys.bookings_apply.tr(context: context),
//                 style: AppTextStyles.medium14.copyWith(
//                   color: context.colors.textTheme,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
