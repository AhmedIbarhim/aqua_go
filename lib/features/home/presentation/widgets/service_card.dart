import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/service_model.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({super.key, required this.serviceModel});

  final ServiceModel serviceModel;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _descriptionExpanded = false;

  ServiceModel get serviceModel => widget.serviceModel;

  bool _isDescriptionLong(String description) => description.length > 60;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final description = context.isEn
        ? serviceModel.rawDescription?.descEn ?? ''
        : serviceModel.rawDescription?.descAr ?? '';
    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, child) => InkWell(
        onTap: () {
          if (user == null) {
            FetchUserData.promptGuestToLogin(context);
          } else {
            context.pushNamed(
              Routes.bookingLocation,
              arguments: BookingFlowStartArgs(service: serviceModel),
            );
          }
        },
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: context.colors.screenBG,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.primary, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: context.isAr ? 0 : null,
                  right: context.isAr ? null : 0,
                  child: Transform.flip(
                    flipX: context.isEn,
                    child: Image.asset(
                      AppAssets.shadows_3,
                      fit: BoxFit.cover,
                      color: context.colors.primary,
                      width: width * 0.45,
                      height: width * 0.45,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(width * 0.035),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.isEn
                                      ? serviceModel.rawName?.nameEn ?? ''
                                      : serviceModel.rawName?.nameAr ?? '',
                                  style: AppTextStyles.bold16,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: AppTextStyles.regular12.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                  maxLines: _descriptionExpanded ? null : 2,
                                  overflow: _descriptionExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),
                                if (_isDescriptionLong(description)) ...[
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _descriptionExpanded =
                                            !_descriptionExpanded;
                                      });
                                    },
                                    child: Text(
                                      _descriptionExpanded
                                          ? LocaleKeys.home_read_less.tr(
                                              context: context,
                                            )
                                          : LocaleKeys.home_read_more.tr(
                                              context: context,
                                            ),
                                      style: AppTextStyles.regular12.copyWith(
                                        color: context.colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (serviceModel.price.isNotEmpty) ...[
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (serviceModel.oldPrice.isNotEmpty) ...[
                                    Text(
                                      serviceModel.oldPrice,
                                      style: AppTextStyles.regular12.copyWith(
                                        color: context.colors.textPrimary
                                            .withValues(alpha: 0.5),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor:
                                            context.colors.textPrimary,
                                        decorationThickness: 0.9,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    serviceModel.price,
                                    style: AppTextStyles.bold18,
                                  ),
                                  const SizedBox(width: 4),
                                  SvgPicture.asset(
                                    AppAssets.currency,
                                    width: 18,
                                    height: 18,
                                    // ignore: deprecated_member_use
                                    color: context.colors.textPrimary,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Transform.flip(
                            flipX: context.isEn,
                            child:
                                serviceModel.imageUrl != null &&
                                    serviceModel.imageUrl!.isNotEmpty
                                ? CustomNetworkImage(serviceModel.imageUrl!)
                                : Image.asset(
                                    context.isDarkTheme
                                        ? AppAssets.baseServiceDark
                                        : AppAssets.baseServiceLight,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
