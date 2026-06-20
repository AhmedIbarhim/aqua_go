import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/features/auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/utils/image_picker_helper.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);

    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, _) => BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            if (user == null) {
              FetchUserData.promptGuestToLogin(context);
            } else {
              final file = await ImagePickerHelper.showImageSourceDialog(
                context,
              );
              if (file != null && context.mounted) {
                context.read<AuthCubit>().uploadAvatar(file.path);
              }
            }
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: sw(134),
                height: sw(134),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.primary,
                  border: Border.all(
                    color: context.colors.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: sw(80),
                            color: context.colors.background,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: sw(80),
                          color: context.colors.background,
                        ),
                ),
              ),
              if (user != null)
                Positioned(
                  right: sw(4),
                  bottom: sw(4),
                  child: Container(
                    padding: EdgeInsets.all(sw(6)),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.background,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: sw(16),
                      color: context.colors.background,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
    );
  }
}
