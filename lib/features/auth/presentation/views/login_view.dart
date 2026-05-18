import 'package:flutter/material.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/login_content.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(
      content: LoginContent(),
    );
  }
}
