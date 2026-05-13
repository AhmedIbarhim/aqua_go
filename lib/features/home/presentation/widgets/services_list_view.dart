import 'package:aqua_go/core/extentions/context_extentions.dart';
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.home_services.tr(),
                style: !context.isTablet
                    ? AppTextStyles.bold16
                    : AppTextStyles.bold18,
              ),
            ],
          ),
        ),
        SizedBox(height: height * 0.012),
        SizedBox(
          height: context.isMobile ? width * 0.3 : height * 0.13,
          child: PageView.builder(
            controller: _pageController,
            itemCount: services.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ServiceCard(serviceModel: services[index]),
            ),
          ),
        ),
      ],
    );
  }
}
