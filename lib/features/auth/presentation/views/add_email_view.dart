import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/auth/controllers/auth_cubit/auth_cubit.dart';
import 'package:aqua_go/features/auth/presentation/widgets/email_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/auth_scaffold.dart';

class AddEmailView extends StatelessWidget {
  const AddEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<AuthCubit>(),
      child: const AuthScaffold(
        content: EmailContent(),
      ),
    );
  }
}
