import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/errors/failure.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepo {
  final AuthService _authService;

  AuthRepo(this._authService);

  Future<Either<Failure, void>> login(String phone) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return const Right(null);
      // final response = await _authService.login(phone);
      // if (response.statusCode == 200) {
      //   return const Right(null);
      // }
      // return Left(ServerFailure('Login failed'));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioExeption(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> verifyOtp({
    required UserModel user,
    required String otp,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // If we have an existing user, we should merge the data or trust the passed user
      // if it contains updates.
      final existingUser = getUser();
      UserModel finalUser = user;

      if (existingUser != null && existingUser.phone == user.phone) {
        // If the passed user has no name but the existing one does, we should keep the existing name
        // (This happens during initial login)
        if (user.name == null && existingUser.name != null) {
          finalUser = existingUser;
        }
      }

      await saveUser(finalUser);
      return Right(finalUser);
      /*
      final response = await _authService.verifyOtp(user.phone ?? '', otp);
      if (response.statusCode == 200) {
        final user = UserModel.fromMap(response.data['data']['user']);
        await saveUser(user);
        return Right(user);
      }
      return Left(ServerFailure('Verification failed'));
      */
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioExeption(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  UserModel? _cachedUser;
  Future<void> saveUser(UserModel user) async {
    _cachedUser = user;
    await SharedPrefs.setString(kUserData, user.toJson());
  }

  UserModel? getUser() {
    if (_cachedUser != null) return _cachedUser;
    final userJson = SharedPrefs.getString(kUserData);
    if (userJson.isNotEmpty) {
      try {
        _cachedUser = UserModel.fromJson(userJson);
        return _cachedUser;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    _cachedUser = null;
    await SharedPrefs.removeString(kUserData);
  }
}
