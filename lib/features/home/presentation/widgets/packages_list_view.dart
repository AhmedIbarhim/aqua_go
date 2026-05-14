import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../data/models/package_model.dart';
import 'package_card.dart';
import '../views/packages_view.dart';

class PackagesListView extends StatefulWidget {
  const PackagesListView({super.key});

  @override
  State<PackagesListView> createState() => _PackagesListViewState();
}

class _PackagesListViewState extends State<PackagesListView> {
  List<PackageModel> packages = [
    PackageModel(
      title: 'باقة اكوا كلاسيك',
      description: '5 غسلات . 5 مجاناً',
      price: '200.00',
      duration: '30 يوم',
      image: 'assets/images/gift_demo.png',
    ),
    PackageModel(
      title: 'باقة اكوا سوبر',
      description: '10 غسلات . 10 مجاناً',
      price: '300.00',
      duration: '30 يوم',
      image: 'assets/images/rocket_demo.png',
    ),
    PackageModel(
      title: 'باقة اكوا بريميوم',
      description:
          '5 غسلات . 5 مجاناًjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj',
      price: '30.00',
      duration: '30 يوم',
      image: 'assets/images/royal_demo.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.home_available_packages.tr(),
                style: !context.isTablet
                    ? AppTextStyles.bold16
                    : AppTextStyles.bold18,
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routes.packages,
                    arguments: PackagesArgs(packages: packages),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      LocaleKeys.home_view_more.tr(),
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: context.colors.primary,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,

                          size: 10,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height * 0.012),
        SizedBox(
          height: context.isMobile ? width * 0.37 : height * 0.175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: packages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                PackageCard(packageModel: packages[index]),
          ),
        ),
      ],
    );
  }
}
