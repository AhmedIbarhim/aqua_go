import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../data/models/service_model.dart';
import 'service_card.dart';

class ServicesListView extends StatefulWidget {
  const ServicesListView({super.key});

  @override
  State<ServicesListView> createState() => _ServicesListViewState();
}

class _ServicesListViewState extends State<ServicesListView> {
  final List<ServiceModel> services = [
    ServiceModel(
      title: 'غسلة (داخلي و خارجي)',
      description: 'تنظيف داخلي و غسيل خارجي مع كنش المراتب. مسح الديكور.',
      price: '90.00',
      oldPrice: '100.00',
      image: 'assets/images/car_demo.png',
    ),
    ServiceModel(
      title: 'غسلة (داخلي و خارجي)',
      description: 'تنظيف داخلي و غسيل خارجي مع كنش المراتب. مسح الديكور.',
      price: '90.00',
      oldPrice: '100.00',
      image: 'assets/images/car_demo.png',
    ),
    ServiceModel(
      title: 'غسلة (داخلي و خارجي)',
      description: 'تنظيف داخلي و غسيل خارجي مع كنش المراتب. مسح الديكور.',
      price: '90.00',
      oldPrice: '100.00',
      image: 'assets/images/car_demo.png',
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
            children: [
              Text(
                'الخدمات',
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
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                ServiceCard(serviceModel: services[index]),
          ),
        ),
      ],
    );
  }
}
