import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
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
  static const int _maxDescriptionChars = 80;

  ServiceModel get serviceModel => widget.serviceModel;

  /// Caps the description at 80 chars (no ellipsis). AutoSizeText then wraps
  /// and shrinks the full capped text to fit the fixed 2-line box.
  String _capDescription(String text) {
    final s = text.trim();
    if (s.length > _maxDescriptionChars) {
      return s.substring(0, _maxDescriptionChars).trim();
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final description = context.isEn
        ? serviceModel.rawDescription?.descEn ?? ''
        : serviceModel.rawDescription?.descAr ?? '';
    final twoLineText = _capDescription(description);
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
                                Builder(
                                  builder: (context) {
                                    final style = AppTextStyles.regular12
                                        .copyWith(
                                          color: context.colors.textSecondary,
                                          height: 1.3,
                                        );
                                    final fontSize = style.fontSize ?? 12;
                                    // Fixed 2-line content box so all cards align.
                                    // AutoSizeText shrinks the full (80-char-capped)
                                    // description to fit exactly 2 wrapped lines —
                                    // never clips mid-word, never truncates with "...".
                                    final twoLineHeight =
                                        fontSize * (style.height ?? 1.3) * 2;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: twoLineHeight,
                                      child: AutoSizeText(
                                        twoLineText,
                                        style: style,
                                        maxLines: 2,
                                        minFontSize: 8,
                                        stepGranularity: 0.5,
                                        wrapWords: true,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.visible,
                                      ),
                                    );
                                  },
                                ),
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
