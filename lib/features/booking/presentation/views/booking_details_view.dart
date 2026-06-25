import 'dart:async';

import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_cars/presentation/controllers/my_cars_cubit.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_deatails_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/car_selection_list.dart';
import '../widgets/package_service_selection_list.dart';
import '../widgets/add_ons_grid.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/package_addon_payment_bottom_sheet.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/helpers/shimmer_helper.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  bool _carJustAdded = false;
  List<MyCarModel> _previousCars = [];

  /// Debounce for the price-lock quote refresh fired on each add-on toggle.
  Timer? _quoteDebounce;

  /// Guards the one-shot initial quote fetch so it runs once per screen mount.
  bool _initialQuoteRequested = false;

  @override
  void initState() {
    super.initState();
    // Lock the price at booking INITIATION: as soon as the priced details
    // screen mounts, capture a fresh server quote that freezes BOTH the service
    // total and every selected add-on. The displayed total reads from this
    // quote only — never from the (potentially stale) live catalog snapshot —
    // so later admin price edits affect only NEW bookings.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<BookingCubit>();
      final state = cubit.state;
      if (state.flowConfig.requiresQuote && !_initialQuoteRequested) {
        _initialQuoteRequested = true;
        cubit.fetchQuote();
      }
    });
  }

  @override
  void dispose() {
    _quoteDebounce?.cancel();
    super.dispose();
  }

  /// Re-locks the price after an add-on toggle. Debounced so rapid toggles
  /// collapse into a single quote refresh. Service flow only — the package
  /// flow uses the wash charge-preview path, not the service quote.
  void _scheduleQuoteRefresh(BookingState state) {
    if (!state.flowConfig.requiresQuote) return;
    _quoteDebounce?.cancel();
    _quoteDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<BookingCubit>().fetchQuote();
    });
  }

  /// Returns true if any currently-selected addon in a package flow requires
  /// payment (optional addons always do; included addons do when free qty = 0).
  bool _requiresPayment(BookingState state) {
    if (!state.flowConfig.isPackage) return false;
    final addons = state.selectedService?.addons ?? [];
    final optionalIds = state.optionalAddonIds;
    final includedIds = state.includedAddonIds;
    for (final idx in state.selectedServiceIndices) {
      if (idx >= addons.length) continue;
      final addon = addons[idx];
      final id = addon.id ?? '';
      if (optionalIds.contains(id)) return true;
      if (includedIds.contains(id) && (addon.freeQty ?? 0) <= 0) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => locator<MyCarsCubit>()..getCars()),
      ],
      child: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          // Only handle submit states for reschedule flow (submits from this view)
          if (!state.flowConfig.showSummaryStep) {
            if (state.status == BookingStatus.loading) {
              context.showLoadingOverlay();
            } else {
              context.hideLoadingOverlay();
            }

            if (state.status == BookingStatus.success) {
              context.showSuccessSnackBar(
                LocaleKeys.bookings_reschedule_success.tr(context: context),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
              if (state.createdBooking != null) {
                Navigator.pushNamed(
                  context,
                  Routes.myBookingDetails,
                  arguments: MyBookingDetailsArgs(
                    booking: BookingSummaryModel.fromDetails(
                      state.createdBooking!,
                    ),
                    isFromBookingFlow: true,
                  ),
                );
              }
            } else if (state.status == BookingStatus.failure) {
              context.showErrorSnackBar(state.errorMessage ?? '');
            }
          }
        },
        builder: (context, bookingState) {
          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: GenericAppBar(
              title: bookingState.flowConfig.isReschedule
                  ? LocaleKeys.bookings_reschedule_booking.tr(context: context)
                  : LocaleKeys.bookings_booking_details.tr(context: context),
              hasBackground: true,
              backgroundImage: AppAssets.bookingHeaderImage,
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildContent(context, bookingState, width, height),
                  ),
                ),
                _buildBottomActionSheet(
                  context,
                  bookingState,
                  width,
                  height * 0.2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState bookingState,
    double width,
    double height,
  ) {
    final config = bookingState.flowConfig;

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.themeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            LocaleKeys.bookings_choose_car.tr(context: context),
            isRequired: true,
          ),
          SizedBox(height: height * 0.02),
          BlocConsumer<MyCarsCubit, MyCarsState>(
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
                    context.read<BookingCubit>().selectCar(myCarsState.cars.last);
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
              if (bookingState.selectedCar != null) {
                selectedCarIndex = cars.indexWhere(
                  (c) => c.id == bookingState.selectedCar!.id,
                );
                if (selectedCarIndex == -1) {
                  selectedCarIndex = cars.indexWhere(
                    (c) =>
                        c.plateNumber == bookingState.selectedCar!.plateNumber,
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
          ),
          if (config.isPackage &&
              (bookingState.packageServices.length > 1 ||
                  bookingState.packageServicesLoading ||
                  bookingState.packageServicesLoadFailed)) ...[
            SizedBox(height: height * 0.03),
            _buildSectionTitle(
              LocaleKeys.bookings_choose_service.tr(context: context),
              isRequired: true,
            ),
            SizedBox(height: height * 0.02),
            if (bookingState.packageServicesLoading)
              SizedBox(
                height: height * 0.14,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (bookingState.packageServicesLoadFailed)
              _buildServicesLoadError(context, width)
            else
              PackageServiceSelectionList(
                services: bookingState.packageServices,
                selectedServiceId: bookingState.selectedPackageService?.id,
                onServiceSelected: (service) {
                  context.read<BookingCubit>().selectPackageService(service);
                },
              ),
          ],
          if (config.showAddOns &&
              bookingState.selectedService != null &&
              bookingState.selectedService!.addons.isNotEmpty) ...[
            SizedBox(height: height * 0.03),
            _buildSectionTitle(LocaleKeys.bookings_additional_services.tr(context: context)),
            SizedBox(height: height * 0.02),
            AddOnsGrid(
              addons: bookingState.selectedService?.addons ?? [],
              selectedIndices: bookingState.selectedServiceIndices,
              onServiceToggled: (index) {
                context.read<BookingCubit>().toggleService(index);
                // Re-lock the price for the new add-on selection (service flow).
                _scheduleQuoteRefresh(bookingState);
              },
              isPackageFlow: config.isPackage,
            ),
          ],
          SizedBox(height: height * 0.02),
          BookingDateTimePicker(
            initialDate: bookingState.selectedDate,
            initialTime: bookingState.selectedTime,
            availabilitySlots: bookingState.availabilitySlots,
            isLoading: bookingState.isAvailabilityLoading,
            onDateChanged: (date) {
              context.read<BookingCubit>().updateDateTime(
                date,
                bookingState.selectedTime,
              );
            },
            onTimeChanged: (time) {
              context.read<BookingCubit>().updateDateTime(
                bookingState.selectedDate,
                time,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
        Text(title, style: AppTextStyles.regular16),
      ],
    );
  }

  /// Inline error + retry shown when the package's bundled services failed to
  /// resolve against the catalog. Replaces the previously-silent hidden picker
  /// (which let a wash submit with serviceId=null).
  Widget _buildServicesLoadError(BuildContext context, double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.bookings_services_load_failed.tr(context: context),
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {
                context.read<BookingCubit>().retryPackageServices();
              },
              child: Text(
                LocaleKeys.retry.tr(context: context),
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSheet(
    BuildContext context,
    BookingState bookingState,
    double width,
    double height,
  ) {
    final config = bookingState.flowConfig;
    // In the package flow, when the bundle has more than one included service
    // the customer must pick one before booking. A single-service bundle is
    // auto-selected, so no extra requirement applies there.
    final servicePicked =
        !config.isPackage ||
        bookingState.packageServices.length <= 1 ||
        bookingState.selectedPackageService != null;
    final isComplete =
        bookingState.selectedCar != null &&
        bookingState.selectedDate != null &&
        bookingState.selectedTime != null &&
        servicePicked;

    // For reschedule flow: submit directly from details view
    if (!config.showSummaryStep) {
      return BottomActionSheetContainer(
        child: CustomButton(
          text: LocaleKeys.bookings_confirm_reschedule.tr(context: context),
          enabled: isComplete,
          onPressed: isComplete
              ? () {
                  context.read<BookingCubit>().submitBooking();
                }
              : null,
        ),
      );
    }

    // For service/package flow: show pricing and navigate to summary.
    //
    // PRICE LOCK: the displayed total comes ONLY from the server quote captured
    // at booking initiation (quote.breakdown.gross) — it freezes both the
    // service price and every selected add-on. We do NOT fall back to the live
    // catalog (selectedService.priceDouble + live add-on prices), so admin price
    // edits made mid-session never change this booking's total. No client-side
    // VAT/price math: the amount is the backend-rendered gross.
    final double? lockedTotal = config.showPricingInDetails
        ? bookingState.quote?.breakdown?.gross
        : null;
    // Block "Book now" on the service flow until the price is locked, so we can
    // never navigate to summary on a live (unlocked) amount.
    final bool priceLocked =
        !config.showPricingInDetails || lockedTotal != null;
    final bool canProceed = isComplete && priceLocked;

    return BottomActionSheetContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (config.showPricingInDetails)
            Row(
              children: [
                Text(
                  LocaleKeys.bookings_total.tr(context: context),
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (lockedTotal == null)
                  Text(
                    LocaleKeys.bookings_calculating_price.tr(context: context),
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  )
                else ...[
                  Text(
                    lockedTotal.toStringAsFixed(2),
                    style: AppTextStyles.medium24,
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    AppAssets.currency,
                    width: width * 0.06,
                    colorFilter: ColorFilter.mode(
                      context.colors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          CustomButton(
            text: LocaleKeys.bookings_book_now.tr(context: context),
            enabled: canProceed,
            onPressed: canProceed
                ? () async {
                    // For package flow with payable addons, collect payment
                    // method before proceeding to the summary screen.
                    if (_requiresPayment(bookingState)) {
                      final confirmed =
                          await PackageAddonPaymentBottomSheet.show(context);
                      if (!context.mounted) return;
                      // User tapped outside or dragged down — abort navigation.
                      if (!confirmed) return;
                    }
                    if (!context.mounted) return;
                    context.pushNamed(
                      Routes.bookingSummary,
                      arguments: BookingFlowArgs(
                        bookingCubit: context.read<BookingCubit>(),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
