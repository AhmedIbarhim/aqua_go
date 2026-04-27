import 'package:flutter/material.dart';
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الباقات المتاحة',
                style: AppTextStyles.bold16.copyWith(color: AppColors.white),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'عرض المزيد',
                    style: AppTextStyles.regular12.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
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
