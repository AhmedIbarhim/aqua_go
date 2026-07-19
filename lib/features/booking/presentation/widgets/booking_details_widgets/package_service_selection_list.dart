import 'package:flutter/material.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../home/data/models/service_model.dart';

/// Horizontal single-select list of the package's included services. Mirrors the
/// car-selection card pattern for visual + interaction consistency. The customer
/// picks exactly one service for the wash.
class PackageServiceSelectionList extends StatelessWidget {
  final List<ServiceModel> services;
  final String? selectedServiceId;
  final void Function(ServiceModel service) onServiceSelected;

  const PackageServiceSelectionList({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: height * 0.14,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (context, index) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          final service = services[index];
          final isSelected = selectedServiceId == service.id;
          return GestureDetector(
            onTap: () => onServiceSelected(service),
            child: _buildServiceCard(
              context,
              service,
              width,
              height,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ServiceModel service,
    double width,
    double height, {
    bool isSelected = false,
  }) {
    final name = context.isEn
        ? (service.rawName?.nameEn ?? '')
        : (service.rawName?.nameAr ?? '');
    return Container(
      width: width * 0.32,
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.brandHover
            : context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: context.colors.primary) : null,
      ),
      child: Center(
        child: Text(
          name,
          style: AppTextStyles.regular14.copyWith(
            color: isSelected
                ? context.colors.textPrimary
                : context.colors.contentDisabled,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
