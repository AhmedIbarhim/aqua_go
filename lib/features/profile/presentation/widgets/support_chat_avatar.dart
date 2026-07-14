import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';

class SupportChatAvatar extends StatelessWidget {
  final bool isAgent;

  const SupportChatAvatar({super.key, required this.isAgent});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);

    return Container(
      width: sw(26),
      height: sw(26),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primary,
      ),
      child: ClipOval(
        child: isAgent
            ? Image.asset(AppAssets.logo, fit: BoxFit.cover)
            : ValueListenableBuilder(
                valueListenable: currentUser,
                builder: (context, user, _) {
                  final imageUrl = user?.imageUrl;
                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: sw(16),
                          height: sw(16),
                          child: CustomLoadingIndicator(size: sw(16)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.person,
                          size: sw(20),
                          color: Colors.black,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Icon(
                      Icons.person,
                      size: sw(20),
                      color: Colors.black,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
