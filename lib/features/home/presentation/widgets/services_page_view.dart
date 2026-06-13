import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/service_model.dart';
import '../controllers/services_controller/services_cubit.dart';
import 'service_card.dart';
import '../../../../core/helpers/shimmer_helper.dart';

class ServicesPageView extends StatefulWidget {
  const ServicesPageView({super.key});

  @override
  State<ServicesPageView> createState() => _ServicesPageViewState();
}

class _ServicesPageViewState extends State<ServicesPageView> {
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cardHeight = context.isMobile ? width * 0.3 : height * 0.13;

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
          height: cardHeight,
          child: BlocBuilder<ServicesCubit, ServicesState>(
            builder: (context, state) {
              if (state is ServicesLoading || state is ServicesInitial) {
                return ShimmerHelper.serviceCard(height: cardHeight);
              }

              if (state is ServicesError) {
                return const SizedBox.shrink();
              }

              final List<ServiceModel> services = state is ServicesLoaded
                  ? state.services
                  : <ServiceModel>[];

              if (services.isEmpty) {
                return Center(
                  child: Text(
                    'No services available',
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                );
              }

              return PageView.builder(
                controller: _pageController,
                itemCount: services.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ServiceCard(serviceModel: services[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
