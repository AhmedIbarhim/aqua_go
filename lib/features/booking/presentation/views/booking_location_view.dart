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
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.bookings_choose_car_location.tr(),
        hasBackground: true,
        backgroundImage: AppAssets.bookingHeaderImage,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                _buildAddressSelectOnMapCard(context),
                const SizedBox(height: 24),
                Text(
                  LocaleKeys.address_my_addresses.tr(),
                  style: AppTextStyles.regular16.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: myAddresses.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final address = myAddresses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
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
                              arguments:
                                  NewAddressMapArgs(forAddingAddress: true),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomActionSheet(context),
        ],
      ),
    );
  }

  Widget _buildAddressSelectOnMapCard(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          Routes.newAddressMap,
          arguments: NewAddressMapArgs(forAddingAddress: false),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.borderSecondary, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(AppAssets.mapOutlined, width: 24),
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

  Widget _buildBottomActionSheet(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: BoxDecoration(color: context.colors.screenBG),
        child: CustomButton(
          text: LocaleKeys.bookings_save_car_location.tr(),
          onPressed: () {
            context.pushNamed(Routes.bookingDetails);
          },
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.borderSecondary, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: context.colors.primary, size: 24),
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
