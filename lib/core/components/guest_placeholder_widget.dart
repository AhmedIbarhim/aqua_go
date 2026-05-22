import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../features/auth/controllers/auth_cubit/auth_cubit.dart';
import '../config/di/service_locator.dart';
import '../extentions/context_extentions.dart';
import '../helpers/fetch_user_data_helper.dart';
import '../themes/app_text_styles.dart';
import '../utils/app_assets.dart';
import '../components/custom_button.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class GuestPlaceholderWidget extends StatelessWidget {
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;

  const GuestPlaceholderWidget({
    super.key,
    this.titleEn = "Log In Required",
    this.titleAr = "تسجيل الدخول مطلوب",
    this.descEn =
        "Please log in to access this feature and enjoy premium car wash services.",
    this.descAr =
        "يرجى تسجيل الدخول للوصول إلى هذه الميزة والاستمتاع بخدمات غسيل السيارات المميزة.",
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    return BlocProvider(
      create: (context) => locator<AuthCubit>(),
      child: Builder(
        builder: (context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.personDisabled,
                        width: 48,
                        height: 48,
                        colorFilter: ColorFilter.mode(
                          context.colors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isAr ? titleAr : titleEn,
                    style: AppTextStyles.semiBold18.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? descAr : descEn,
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    child: CustomButton(
                      onPressed: () {
                        FetchUserData.promptGuestToLogin(context);
                      },
                      text: LocaleKeys.auth_login.tr(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
