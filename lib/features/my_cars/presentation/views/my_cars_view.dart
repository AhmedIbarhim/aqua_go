import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors_extension.dart';
import '../widgets/my_cars_list_view.dart';

class MyCarsView extends StatelessWidget {
  const MyCarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(child: MyCarsListView()),
        ],
      ),
    );
  }
}
