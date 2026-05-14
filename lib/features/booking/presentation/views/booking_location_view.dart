import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../adress/controllers/addresses_controller/addresses_cubit.dart';
import '../../../adress/controllers/maps_controller/maps_cubit.dart';
import '../widgets/location_selection_card.dart';
import '../../../adress/presentation/views/new_address_map_view.dart';

class BookingLocationView extends StatefulWidget {
  const BookingLocationView({super.key});

  @override
  State<BookingLocationView> createState() => _BookingLocationViewState();
}

class _BookingLocationViewState extends State<BookingLocationView> {
  int selectedLocationIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => locator<MapsCubit>()..determinePosition(),
        ),
        BlocProvider.value(value: AddressesCubit()..getAddresses()),
      ],
      child: Scaffold(
        backgroundColor: context.colors.screenBG,
        appBar: GenericAppBar(
          title: LocaleKeys.bookings_choose_car_location.tr(),
          hasBackground: true,
          backgroundImage: AppAssets.bookingHeaderImage,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(width * 0.06),
                        decoration: BoxDecoration(
                          color: context.colors.background,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.address_map.tr(),
                              style: AppTextStyles.regular16.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            BlocBuilder<MapsCubit, MapsState>(
                              builder: (context, state) {
                                return LocationSelectionCard(
                                  icon: AppAssets.gps,
                                  title: LocaleKeys.address_current_location
                                      .tr(),
                                  subtitle: state.isLoading
                                      ? '...'
                                      : state.selectedAddressName.isEmpty
                                      ? '__'
                                      : state.selectedAddressName,
                                  isSelected: selectedLocationIndex == 0,
                                  onTap: () {
                                    setState(() {
                                      selectedLocationIndex = 0;
                                    });
                                  },
                                );
                              },
                            ),
                            SizedBox(height: height * 0.01),
                            _buildAddressSelectOnMapCard(context, width),
                            SizedBox(height: height * 0.03),
                            Text(
                              LocaleKeys.address_my_addresses.tr(),
                              style: AppTextStyles.regular16.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            BlocBuilder<AddressesCubit, AddressesState>(
                              builder: (context, state) {
                                if (state is AddressesLoaded) {
                                  return ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: state.addresses.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      final address = state.addresses[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: height * 0.01,
                                        ),
                                        child: LocationSelectionCard(
                                          icon: AppAssets.location,
                                          title: address.name,
                                          subtitle: address.formattedAddress,
                                          isSelected:
                                              selectedLocationIndex ==
                                              index + 1,
                                          onTap: () {
                                            setState(() {
                                              selectedLocationIndex = index + 1;
                                            });
                                          },
                                          onEdit: () {},
                                        ),
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            CustomButton(
                              color: context.colors.background,
                              borderColor: context.colors.borderSecondary,
                              textColor: context.colors.primary,
                              preWidget: Icon(
                                Icons.add,
                                color: context.colors.primary,
                                size: width * 0.06,
                              ),
                              text: LocaleKeys.address_add_new_location.tr(),
                              onPressed: () {
                                context.pushNamed(
                                  Routes.newAddressMap,
                                  arguments: NewAddressMapArgs(
                                    forAddingAddress: true,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildBottomActionSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelectOnMapCard(BuildContext context, double width) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          Routes.newAddressMap,
          arguments: NewAddressMapArgs(forAddingAddress: false),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.borderSecondary, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(AppAssets.mapOutlined, width: width * 0.06),

            const SizedBox(width: 8),
            Text(
              LocaleKeys.address_select_on_map.tr(),
              style: AppTextStyles.regular16.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionSheet() {
    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_save_car_location.tr(),
        onPressed: () {
          context.pushNamed(Routes.bookingDetails);
        },
      ),
    );
  }
}
