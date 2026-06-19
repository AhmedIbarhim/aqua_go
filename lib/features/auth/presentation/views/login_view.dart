import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/login_content.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<AuthCubit>()..clearStaleSession(),
      child: const AuthScaffold(
        content: LoginContent(),
      ),
    );
  }
}
