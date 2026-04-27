import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../data/models/package_model.dart';
import 'package_card.dart';

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
      price: '30.00',
      duration: '30 يوم',
      image: 'assets/images/gift_demo.png',
    ),
    PackageModel(
      title: 'باقة اكوا سوبر',
      description: '5 غسلات . 5 مجاناً',
      price: '30.00',
      duration: '30 يوم',
      image: 'assets/images/rocket_demo.png',
    ),
    PackageModel(
      title: 'باقة اكوا بريميوم',
      description: '5 غسلات . 5 مجاناً',
      price: '30.00',
      duration: '30 يوم',
      image: 'assets/images/royal_demo.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
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
                style: AppTextStyles.bold16.copyWith(color: AppColors.white),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(Routes.packages, arguments: packages);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      LocaleKeys.home_view_more.tr(),
                      style: AppTextStyles.regular12.copyWith(
                        color: AppColors.primary,
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
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          context.isAr
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_back_ios,
                          size: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: height * 0.16,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                PackageCard(packageModel: packages[index]),
          ),
        ),
      ],
    );
  }
}
