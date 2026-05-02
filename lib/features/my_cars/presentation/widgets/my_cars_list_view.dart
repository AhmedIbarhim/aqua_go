import 'package:aqua_go/core/components/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/my_car_model.dart';
import 'my_car_card.dart';

class MyCarsListView extends StatelessWidget {
  const MyCarsListView({super.key, required this.cars});
  final List<MyCarModel> cars;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        CustomButton(
          text: LocaleKeys.my_cars_add_car.tr(),
          preWidget: Icon(Icons.add),
          onPressed: () {},
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => MyCarCard(car: cars[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: cars.length,
          ),
        ),
      ],
    );
  }
}
