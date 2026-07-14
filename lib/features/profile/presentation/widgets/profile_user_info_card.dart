import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import '../../../rating/presentation/widgets/rating_widget.dart';

class ProfileUserInfoCard extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileUserInfoCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);

    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, _) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw(12)),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(color: context.colors.borderSecondary),
          borderRadius: BorderRadius.circular(sw(12)),
        ),
        child: Row(
          children: [
            Container(
              width: sw(40),
              height: sw(40),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(sw(8)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.personDisabled,
                  width: sw(20),
                  height: sw(20),
                  colorFilter: ColorFilter.mode(
                    context.colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: sw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? FetchUserData.getUserName(),
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  RatingWidget(
                    rating: FetchUserData.getUserRating(),
                    showRatingValue: user != null && FetchUserData.getUserRating() > 0,
                    ratingTextStyle: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
