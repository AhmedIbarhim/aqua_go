import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/custom_radio_widget.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../controllers/send_gift_cubit.dart';

class GiftPaymentMethodCard extends StatelessWidget {
  final String method;
  final String title;
  final List<String> iconPaths;
  final bool isSelected;

  const GiftPaymentMethodCard({
    super.key,
    required this.method,
    required this.title,
    required this.iconPaths,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SendGiftCubit>().updatePaymentMethod(method);
      },
      child: Container(
        padding: EdgeInsets.all(context.sw(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover
              : context.colors.themeColor,
          borderRadius: BorderRadius.circular(context.sw(16)),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bold13.copyWith(
                      fontSize: context.sw(13),
                      color: isSelected
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: iconPaths
                        .map(
                          (path) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sw(2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                context.sw(4),
                              ),
                              child: Image.asset(
                                path,
                                height: context.sh(20),
                                width: context.sw(30),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.sw(16)),
            CustomRadioWidget(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
