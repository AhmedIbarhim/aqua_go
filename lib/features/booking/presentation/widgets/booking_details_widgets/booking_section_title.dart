import 'package:flutter/material.dart';
import '../../../../../core/themes/app_text_styles.dart';

class BookingSectionTitle extends StatelessWidget {
  final String title;
  final bool isRequired;

  const BookingSectionTitle({
    super.key,
    required this.title,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
        Text(title, style: AppTextStyles.regular16),
      ],
    );
  }
}
