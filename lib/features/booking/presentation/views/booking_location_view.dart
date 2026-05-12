import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../adress/data/models/address_model.dart';
import '../widgets/location_selection_card.dart';
import '../../../adress/presentation/views/new_address_map_view.dart';

class BookingLocationView extends StatefulWidget {
  const BookingLocationView({super.key});

  @override
  State<BookingLocationView> createState() => _BookingLocationViewState();
}

class _BookingLocationViewState extends State<BookingLocationView> {
  int selectedLocationIndex = 0;

  final List<AddressModel> myAddresses = [
    AddressModel(
      name: 'المنزل',
      formattedAddress: '12شارع الماسة, الرياض السعودية',
      lat: 24.7136,
      lng: 46.6753,
    ),
    AddressModel(
      name: 'المكتب',
      formattedAddress: '1شارع الدار البيضاء, الرياض السعودية',
      lat: 24.7136,
      lng: 46.6753,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
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
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(width * 0.06),
                decoration: BoxDecoration(color: context.colors.background),
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
                    LocationSelectionCard(
                      icon: AppAssets.gps,
                      title: LocaleKeys.address_current_location.tr(),
                      subtitle: 'شارع احمد عبد الخالق, نجران السعودية',
                      isSelected: selectedLocationIndex == 0,
                      onTap: () {
                        setState(() {
                          selectedLocationIndex = 0;
                        });
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
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: myAddresses.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final address = myAddresses[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: height * 0.01),
                          child: LocationSelectionCard(
                            icon: AppAssets.location,
                            title: address.name.tr(),
                            subtitle: address.formattedAddress,
                            isSelected: selectedLocationIndex == index + 1,
                            onTap: () {
                              setState(() {
                                selectedLocationIndex = index + 1;
                              });
                            },
                            onEdit: () {},
                          ),
                        );
                      },
                    ),
                    AddNewAddressButton(
                      text: LocaleKeys.address_add_new_location.tr(),
                      onTap: () {
                        context.pushNamed(
                          Routes.newAddressMap,
                          arguments: NewAddressMapArgs(forAddingAddress: true),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActionSheet(),
        ],
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
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: context.colors.brandHover,
                shape: BoxShape.circle,
              ),
            ),
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

class AddNewAddressButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AddNewAddressButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.borderSecondary, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: context.colors.primary, size: width * 0.06),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.medium14.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
