import 'package:aqua_go/core/components/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/my_car_model.dart';
import 'my_car_card.dart';

class MyCarsListView extends StatefulWidget {
  const MyCarsListView({super.key});

  @override
  State<MyCarsListView> createState() => _MyCarsListViewState();
}

class _MyCarsListViewState extends State<MyCarsListView> {
  final List<MyCarModel> cars = List.generate(
    3,
    (index) => MyCarModel(
      name: "تويوتا",
      color: "أسود",
      model: "لاند كروزر",
      year: "2023",
      image: AppAssets.demoLandcroser,
      typeImage: AppAssets.demoToyota,
      boardNumber: "W E F 5846",
    ),
  );
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
