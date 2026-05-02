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
    cars = List.generate(
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
