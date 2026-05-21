import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../widgets/empty_cars_widget.dart';
import '../widgets/my_cars_list_view.dart';
import '../../data/models/my_car_model.dart';
import '../../controllers/my_cars_cubit.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/components/guest_placeholder_widget.dart';

class MyCarsView extends StatefulWidget {
  const MyCarsView({super.key});

  @override
  State<MyCarsView> createState() => _MyCarsViewState();
}

class _MyCarsViewState extends State<MyCarsView> {
  final MyCarsCubit _myCarsCubit = locator<MyCarsCubit>();

  @override
  void initState() {
    if (!FetchUserData.isGuest()) {
      _myCarsCubit.getCars();
    }
    super.initState();
  }

  @override
  void dispose() {
    _myCarsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FetchUserData.isGuest()) {
      return Container(
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
        child: const GuestPlaceholderWidget(
          titleEn: "Your Vehicles",
          titleAr: "مركباتك",
          descEn: "Please log in to manage your vehicles and access booking services.",
          descAr: "يرجى تسجيل الدخول لإدارة سياراتك والوصول إلى خدمات الحجز.",
        ),
      );
    }

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
        child: BlocConsumer<MyCarsCubit, MyCarsState>(
          listener: (context, state) {
            if (state is MyCarsActionLoading) {
              context.showLoadingOverlay();
            } else {
              context.hideLoadingOverlay();
            }

            if (state is MyCarsActionError) {
              context.showWarningAlert(
                title: 'Error',
                message: state.message,
                primaryButtonText: 'OK',
              );
            }
          },
          buildWhen: (previous, current) =>
              current is MyCarsLoading ||
              current is MyCarsLoaded ||
              current is MyCarsError ||
              current is MyCarsInitial,
          builder: (context, state) {
            if (state is MyCarsLoading || state is MyCarsInitial) {
              return ShimmerHelper.cars();
            }
            if (state is MyCarsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(
                        color: context.colors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _myCarsCubit.getCars(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
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
