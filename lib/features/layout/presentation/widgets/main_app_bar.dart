import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../notifications/presentation/controllers/notifications_cubit/notifications_cubit.dart';
import '../../../notifications/presentation/controllers/notifications_cubit/notifications_state.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = FetchUserData.getUserName();
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sh(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: context.isMobile ? sw(40) : sw(30),
                  height: context.isMobile ? sw(40) : sw(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.primary, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sw(40)),
                    child: FetchUserData.getAvatarUrl() != null
                        ? CachedNetworkImage(
                            imageUrl: FetchUserData.getAvatarUrl()!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: sw(16),
                                height: sw(16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: context.colors.primary,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: context.colors.primary,
                          ),
                  ),
                ),
                SizedBox(width: sw(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${LocaleKeys.layout_welcome.tr()} $userName.',
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          LocaleKeys.layout_ready_to_serve.tr(),
                          style: AppTextStyles.medium14,
                        ),
                        SizedBox(width: sw(4)),
                        Image.asset(
                          AppAssets.wavingHand,
                          width: sw(16),
                          height: sw(16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Left Side: Gift and Notifications
            Row(
              children: [
                BlocProvider(
                  create: (context) =>
                      locator<NotificationsCubit>()..fetchUnreadCount(),
                  child: BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, state) {
                      final int unreadCount = state is NotificationsSuccess
                          ? state.unreadCount
                          : 0;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await context.pushNamed(Routes.notification);
                              if (context.mounted) {
                                context
                                    .read<NotificationsCubit>()
                                    .fetchUnreadCount();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(sw(8)),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(sw(8)),
                              ),
                              child: SvgPicture.asset(
                                AppAssets.notification,
                                width: sw(24),
                                height: sw(24),
                                placeholderBuilder: (context) =>
                                    SizedBox(width: sw(24), height: sw(24)),
                                colorFilter: ColorFilter.mode(
                                  context.colors.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              left: context.isEn ? sw(8) : null,
                              right: context.isAr ? sw(8) : null,
                              top: sw(4),
                              child: Container(
                                padding: EdgeInsets.all(sw(2)),
                                decoration: BoxDecoration(
                                  color: context.colors.warning,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.colors.screenBG,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sw(9),
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(width: sw(8)),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(sw(8)),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(sw(8)),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.gift,
                      width: sw(24),
                      height: sw(24),
                      placeholderBuilder: (context) =>
                          SizedBox(width: sw(24), height: sw(24)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
