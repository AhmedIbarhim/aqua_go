import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/utils/app_assets.dart' show AppAssets;
import '../../data/models/my_car_model.dart';
import '../widgets/empty_cars_widget.dart';
import '../widgets/my_cars_list_view.dart';

class MyCarsView extends StatefulWidget {
  const MyCarsView({super.key});

  @override
  State<MyCarsView> createState() => _MyCarsViewState();
}

class _MyCarsViewState extends State<MyCarsView> {
  List<MyCarModel> cars = [];

  @override
  void initState() {
    super.initState();
    cars = [
      MyCarModel(
        name: "نيسان",
        colorCode: 0xFF7f1d1d,
        model: "صني",
        year: "2022",
        image: AppAssets.myCar,
        typeImage: AppAssets.demoToyota,
        boardNumber: "W E F 5846",
      ),
      MyCarModel(
        name: "نيسان",
        colorCode: 0xFF4b5563,
        model: "صني",
        year: "2022",
        image: AppAssets.myCar,
        typeImage: AppAssets.demoToyota,
        boardNumber: "W E F 5846",
      ),
      MyCarModel(
        name: "تويوتا",
        colorCode: 0xFF7c4a2d,
        model: "لاند كروزر",
        year: "2023",
        image: AppAssets.myCar,
        typeImage: AppAssets.demoToyota,
        boardNumber: "W E F 5846",
      ),
      MyCarModel(
        name: "هيونداي",
        colorCode: 0xFF1e3a8a,
        model: "توسان",
        year: "2024",
        image: AppAssets.myCar,
        typeImage: AppAssets.demoToyota,
        boardNumber: "W E F 5846",
      ),
    ];
  }

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
          if (cars.isEmpty)
            Expanded(child: const EmptyCarsWidget())
          else
            Expanded(child: MyCarsListView(cars: cars)),
        ],
      ),
    );
  }
}
