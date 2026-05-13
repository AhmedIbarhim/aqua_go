import 'package:aqua_go/core/components/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/route/routes.dart';
import '../../data/models/my_car_model.dart';
import 'my_car_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/my_cars_cubit.dart';

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
          preWidget: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, Routes.addVehicle);
          },
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final car = cars[index];
              return MyCarCard(
                car: car,
                onEdit: () {
                  Navigator.pushNamed(context, Routes.addVehicle,
                      arguments: car);
                },
                onDelete: () {
                  context.read<MyCarsCubit>().deleteCar(car.id);
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: cars.length,
          ),
        ),
      ],
    );
  }
}
