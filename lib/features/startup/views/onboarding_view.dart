import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/shared_prefs.dart';
import '../../../core/constants.dart';
import '../../../core/controllers/language_controller/language_cubit.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../widgets/language_widget.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        final int next = _pageController.page!.round();
        if (next != currentPage) {
          setState(() {
            currentPage = next;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageCubit>(); // Force rebuild on language change
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                AppAssets.onboardingShadowTop,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(top: 60, left: 24, child: const LanguageWidget()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomContainer(context),
          ),
          Positioned(
            top: height * 0.30,
            left: 0,
            right: 0,
            child: OnboardingPageView(pageController: _pageController),
          ),
        ],
      ),
    );
  }

  Container _buildBottomContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.33,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          left: 24.0,
          right: 24.0,
          bottom: 48.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              currentPage == 0
                  ? LocaleKeys.onboarding_title1.tr()
                  : currentPage == 1
                  ? LocaleKeys.onboarding_title2.tr()
                  : LocaleKeys.onboarding_title3.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.semiBold24,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.16,
              child: Text(
                currentPage == 0
                    ? LocaleKeys.onboarding_desc1.tr()
                    : currentPage == 1
                    ? LocaleKeys.onboarding_desc2.tr()
                    : LocaleKeys.onboarding_desc3.tr(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regular16.copyWith(
                  color: AppColors.contentDisabled,
                ),
              ),
            ),
            const SizedBox(height: 16),

            ListenableBuilder(
              listenable: _pageController,
              builder: (context, child) {
                return DotsIndicator(
                  dotsCount: 3,
                  position: _pageController.hasClients
                      ? _pageController.page!
                      : 0,
                  decorator: DotsDecorator(
                    activeColor: AppColors.primary,
                    color: Colors.white54.withValues(alpha: 0.2),
                    size: const Size(18, 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    spacing: const EdgeInsets.all(4),
                    activeSize: const Size(30, 6),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildDownButton(context, currentPage),
          ],
        ),
      ),
    );
  }

  Widget _buildDownButton(BuildContext context, int currentPage) {
    if (currentPage < 2) {
      return Row(
        children: [
          GestureDetector(
            onTap: () {
              SharedPrefs.setBool(kNotFirstUse, true);
              Navigator.pushReplacementNamed(context, Routes.login);
            },
            child: Text(
              LocaleKeys.skip.tr(),
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: CustomButton(
              text: LocaleKeys.next.tr(),
              postWidget: const Icon(
                Icons.arrow_forward,
                color: AppColors.black,
              ),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      );
    } else {
      return CustomButton(
        text: LocaleKeys.get_started.tr(),
        onPressed: () {
          SharedPrefs.setBool(kNotFirstUse, true);
          Navigator.pushReplacementNamed(context, Routes.login);
        },
      );
    }
  }
}
