import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

import '../config/networking/endpoints.dart';

class FetchUserData {
  static UserModel? getUser() {
    return locator<AuthRepository>().getUser();
  }

  static String getUserName() {
    return getUser()?.name ?? LocaleKeys.guest.tr();
  }

  static String getPhone() {
    return getUser()?.phone ?? '';
  }

  static String getGender() {
    return getUser()?.gender ?? '';
  }

  static DateTime? getBirthdate() {
    return getUser()?.birthdate;
  }

  static String? getAvatarUrl() {
    final name = getUser()?.name;
    return name != null ? Endpoints.nameAvatar(name) : null;
  }

  static String? getEmail() {
    return getUser()?.email;
  }

  static String? getUserId() {
    return getUser()?.id;
  }

  static bool getIsLoggedIn() {
    return getUser() != null;
  }
}
