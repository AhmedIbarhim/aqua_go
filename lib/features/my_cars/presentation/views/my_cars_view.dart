import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../widgets/empty_cars_widget.dart';
import '../widgets/my_cars_list_view.dart';
import '../../data/models/my_car_model.dart';
import '../../controllers/my_cars_cubit.dart';

class MyCarsView extends StatefulWidget {
  const MyCarsView({super.key});

  @override
  State<MyCarsView> createState() => _MyCarsViewState();
}

class _MyCarsViewState extends State<MyCarsView> {
  final MyCarsCubit _myCarsCubit = locator<MyCarsCubit>();

  @override
  void initState() {
    _myCarsCubit.getCars();
    super.initState();
  }

  @override
  void dispose() {
    _myCarsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _myCarsCubit,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BlocBuilder<MyCarsCubit, MyCarsState>(
          builder: (context, state) {
            final List<MyCarModel> cars = state is MyCarsLoaded
                ? state.cars
                : <MyCarModel>[];
            return Column(
              children: [
                const SizedBox(height: 12),
                if (cars.isEmpty)
                  const Expanded(child: EmptyCarsWidget())
                else
                  Expanded(child: MyCarsListView(cars: cars)),
              ],
            );
          },
        ),
      ),
    );
  }
}
