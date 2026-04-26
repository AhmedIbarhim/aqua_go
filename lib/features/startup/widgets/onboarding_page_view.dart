import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.pageController});
  final PageController pageController;

  List<Widget> get pages => [
    SvgPicture.asset(AppAssets.onboarding1, fit: BoxFit.fill),
    SvgPicture.asset(AppAssets.onboarding2, fit: BoxFit.fill),
    SvgPicture.asset(AppAssets.onboarding3, fit: BoxFit.fill),
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.35,
      width: double.infinity,
      child: PageView.builder(
        controller: pageController,
        itemCount: 3,
        itemBuilder: (context, index) => pages[index],
      ),
    );
  }
}
