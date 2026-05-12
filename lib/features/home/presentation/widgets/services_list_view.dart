import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
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
      description:
          'تنظيف داخلي و غسيل خارجي مع كنش المراتب. مسح الديكوssssssssssssssssssssssssssssssssssssssر.',
      price: '90.00',
      oldPrice: '100.00',
      image: 'assets/images/car_demo.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(LocaleKeys.home_services.tr(), style: AppTextStyles.bold16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: width * 0.3,
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
