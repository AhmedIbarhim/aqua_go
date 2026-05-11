import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/local_storage/shared_prefs.dart';
import '../../../core/constants.dart';
import '../../../core/config/controllers/language_controller/language_cubit.dart';
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
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: darkAppColors.themeOpositeColor,
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

          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Expanded(
                child: OnboardingPageView(pageController: _pageController),
              ),
              _buildBottomContainer(context, isSmallScreen),
            ],
          ),
          Positioned(top: 48, left: 24, child: LanguageWidget()),
        ],
      ),
    );
  }

  Widget _buildBottomContainer(BuildContext context, bool isSmallScreen) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkAppColors.themeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: isSmallScreen ? 20.0 : 32.0,
          left: 24.0,
          right: 24.0,
          bottom: isSmallScreen ? 24.0 : 48.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
            SizedBox(height: isSmallScreen ? 12 : 16),
            SizedBox(
              height: isSmallScreen ? size.height * 0.07 : size.height * 0.08,
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
                  color: darkAppColors.contentDisabled,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            ListenableBuilder(
              listenable: _pageController,
              builder: (context, child) {
                double position = 0;
                if (_pageController.hasClients &&
                    _pageController.position.hasContentDimensions) {
                  position = _pageController.page ?? currentPage.toDouble();
                } else {
                  position = currentPage.toDouble();
                }
                return DotsIndicator(
                  dotsCount: 3,
                  position: position,
                  decorator: DotsDecorator(
                    activeColor: darkAppColors.primary,
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
            SizedBox(height: isSmallScreen ? 20 : 32),
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
                color: darkAppColors.themeOpositeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: CustomButton(
              text: LocaleKeys.next.tr(),
              postWidget: Icon(
                Icons.arrow_forward,
                color: darkAppColors.themeColor,
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
