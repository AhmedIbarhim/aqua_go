import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/route/routes.dart';
import '../../../../../core/helpers/shimmer_helper.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../my_cars/presentation/controllers/my_cars_cubit.dart';
import '../../../../my_cars/data/models/my_car_model.dart';
import '../../controllers/booking_cubit.dart';
import '../../controllers/booking_state.dart';
import 'car_selection_list.dart';

class CarSelectionSection extends StatefulWidget {
  final BookingState bookingState;

  const CarSelectionSection({
    super.key,
    required this.bookingState,
  });

  @override
  State<CarSelectionSection> createState() => _CarSelectionSectionState();
}

class _CarSelectionSectionState extends State<CarSelectionSection> {
  bool _carJustAdded = false;
  List<MyCarModel> _previousCars = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyCarsCubit, MyCarsState>(
      listener: (context, myCarsState) {
        if (myCarsState is MyCarsLoaded) {
          if (_carJustAdded) {
            _carJustAdded = false;
            MyCarModel? newCar;
            for (final car in myCarsState.cars) {
              final exists = _previousCars.any((c) => c.id == car.id);
              if (!exists) {
                newCar = car;
                break;
              }
            }
            if (newCar != null) {
              context.read<BookingCubit>().selectCar(newCar);
            } else if (myCarsState.cars.isNotEmpty) {
              context.read<BookingCubit>().selectCar(
                myCarsState.cars.last,
              );
            }
          }
          _previousCars = myCarsState.cars;
        }
      },
      builder: (context, myCarsState) {
        if (myCarsState is MyCarsLoading ||
            myCarsState is MyCarsInitial) {
          return ShimmerHelper.bookingCars(
            onAddCar: () {
              context.pushNamed(Routes.addVehicle).then((val) {
                if (val == true && context.mounted) {
                  setState(() {
                    _carJustAdded = true;
                  });
                  context.read<MyCarsCubit>().getCars();
                }
              });
            },
          );
        }
        final cars = myCarsState is MyCarsLoaded
            ? myCarsState.cars
            : <MyCarModel>[];
        int? selectedCarIndex;
        if (widget.bookingState.selectedCar != null) {
          selectedCarIndex = cars.indexWhere(
            (c) => c.id == widget.bookingState.selectedCar!.id,
          );
          if (selectedCarIndex == -1) {
            selectedCarIndex = cars.indexWhere(
              (c) =>
                  c.plateNumber == widget.bookingState.selectedCar!.plateNumber,
            );
            if (selectedCarIndex != -1) {
              final realCar = cars[selectedCarIndex];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<BookingCubit>().selectCar(realCar);
                }
              });
            } else {
              selectedCarIndex = null;
            }
          }
        }

        return CarSelectionList(
          cars: cars,
          selectedCarIndex: selectedCarIndex,
          onCarSelected: (index) {
            context.read<BookingCubit>().selectCar(cars[index]);
          },
          onAddCar: () {
            context.pushNamed(Routes.addVehicle).then((val) {
              if (val == true && context.mounted) {
                setState(() {
                  _carJustAdded = true;
                });
                context.read<MyCarsCubit>().getCars();
              }
            });
          },
        );
      },
    );
  }
}
