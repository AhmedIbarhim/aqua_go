import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _excecuteSplashAnimation();

    _checkNavigation();
  }

  void _excecuteSplashAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  bool _isProfileComplete(UserModel u) {
    return (u.name?.trim().isNotEmpty ?? false)
    //  &&
    //     (u.gender?.trim().isNotEmpty ?? false) &&
    //     u.birthdate != null
    ;
  }

  void _goToPreAuth() {
    final isNotFirstUse = CacheClient.getBool(kNotFirstUse);
    context.pushReplacementNamed(
      isNotFirstUse ? Routes.login : Routes.onboarding,
    );
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // install-marker gate: SharedPrefs is wiped on reinstall but
    // Keychain survives, so an absent marker means any stored token is stale.
    final installed = CacheClient.getBool(kSessionInstallMarker);
    if (!installed) {
      await locator<AuthRepository>().purgeLocalSession();
      await CacheClient.setBool(kSessionInstallMarker, true);
      if (!mounted) return;
      _goToPreAuth();
      return;
    }

    // server-validated routing.
    final token = await SecureStorage.getSecuredString(kAccessToken);
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      _goToPreAuth();
      return;
    }

    final result = await locator<AuthRepository>().refreshProfile();
    if (!mounted) return;

    result.fold(
      (failure) async {
        if (failure.type == FailureType.network ||
            failure.type == FailureType.timeout) {
          // Offline grace: trust cached identity if complete.
          final cached = locator<AuthRepository>().getUser();
          if (cached != null && _isProfileComplete(cached)) {
            context.pushReplacementNamed(Routes.layout);
          } else {
            _goToPreAuth();
          }
        } else {
          // Broken/expired session — log out fully and go to login.
          await locator<AuthRepository>().logout();
          if (!mounted) return;
          context.pushReplacementNamed(Routes.login);
        }
      },
      (user) {
        if (_isProfileComplete(user)) {
          context.pushReplacementNamed(Routes.layout);
        } else {
          context.pushReplacementNamed(Routes.profileData, arguments: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.splashColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(AppAssets.logo),
          ),
        ),
      ),
    );
  }
}
