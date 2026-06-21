import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.pageController});
  final PageController pageController;

  static List<String> getEnStepImagesForPage(int index) {
    switch (index) {
      case 0:
        return [
          AppAssets.onPOneIOneEn,
          AppAssets.onPOneITwoEn,
          AppAssets.onPOneIThreeEn,
          AppAssets.onPOneIFourEn,
          AppAssets.onPOneIFiveEn,
        ];
      case 1:
        return [
          AppAssets.onPTwoIOneEn,
          AppAssets.onPTwoITwoEn,
          AppAssets.onPTwoIThreeEn,
          AppAssets.onPTwoIFourEn,
        ];
      case 2:
      default:
        return [
          AppAssets.onPThreeIOneEn,
          AppAssets.onPThreeITwoEn,
          AppAssets.onPThreeIThreeEn,
        ];
    }
  }

  static List<String> getArStepImagesForPage(int index) {
    switch (index) {
      case 0:
        return [
          AppAssets.onPOneIOneAr,
          AppAssets.onPOneITwoAr,
          AppAssets.onPOneIThreeAr,
          AppAssets.onPOneIFourAr,
          AppAssets.onPOneIFiveAr,
        ];
      case 1:
        return [
          AppAssets.onPTwoIOneAr,
          AppAssets.onPTwoITwoAr,
          AppAssets.onPTwoIThreeAr,
          AppAssets.onPTwoIFourAr,
        ];
      case 2:
      default:
        return [
          AppAssets.onPThreeIOneAr,
          AppAssets.onPThreeITwoAr,
          AppAssets.onPThreeIThreeAr,
        ];
    }
  }

  List<String> get backgroundImages => [
    AppAssets.onboarding1,
    AppAssets.onboarding2,
    AppAssets.onboarding3,
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: backgroundImages.length,
      itemBuilder: (context, index) =>
          Image.asset(backgroundImages[index], fit: BoxFit.contain),
    );
  }
}
