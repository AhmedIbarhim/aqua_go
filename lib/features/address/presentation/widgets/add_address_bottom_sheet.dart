import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/custom_text_form_field.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../data/models/address_model.dart';
import '../../../../core/config/di/service_locator.dart';
import '../controllers/addresses_controller/addresses_cubit.dart';
import '../views/new_address_map_view.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final String address;
  final double lat;
  final double lng;
  final AddressModel? existingAddress;

  const AddAddressBottomSheet({
    super.key,
    required this.address,
    required this.lat,
    required this.lng,
    this.existingAddress,
  });

  static void show({
    required BuildContext context,
    required String address,
    required double lat,
    required double lng,
    AddressesCubit? addressesCubit,
    AddressModel? existingAddress,
  }) {
    CustomBottomSheet.show(
      context: context,
      title: existingAddress == null
          ? LocaleKeys.address_add_new_location.tr()
          : LocaleKeys.address_edit_location.tr(),
      child: addressesCubit != null
          ? BlocProvider.value(
              value: addressesCubit,
              child: AddAddressBottomSheet(
                address: address,
                lat: lat,
                lng: lng,
                existingAddress: existingAddress,
              ),
            )
          : BlocProvider(
              create: (context) => locator<AddressesCubit>(),
              child: AddAddressBottomSheet(
                address: address,
                lat: lat,
                lng: lng,
                existingAddress: existingAddress,
              ),
            ),
    );
  }

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _accessNotesController = TextEditingController();
  late final TextEditingController _addressController;
  late double _lat;
  late double _lng;

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _lng = widget.lng;
    _addressController = TextEditingController(text: widget.address);
    if (widget.existingAddress != null) {
      _addressNameController.text = widget.existingAddress!.label;
      _accessNotesController.text = widget.existingAddress!.arrivalNotes ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressNameController.dispose();
    _accessNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocConsumer<AddressesCubit, AddressesState>(
      listener: (context, state) {
        if (state is AddressesActionLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state is AddressesActionSuccess) {
          Navigator.pop(context); // Close bottom sheet
          if (widget.existingAddress == null) {
            Navigator.pop(context); // Return from map view
          }
        }

        if (state is AddressesActionError) {
          if (state.message == 'address-outside-service-area') {
            context.showErrorSnackBar(
              LocaleKeys.address_zone_not_available.tr(),
            );
          } else {
            context.showErrorSnackBar(state.message);
          }
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(
              LocaleKeys.address_address_label.tr(),
              isRequired: true,
            ),
            SizedBox(height: height * 0.01),
            CustomTextFormField(
              controller: _addressController,
              label: LocaleKeys.address_address_label.tr(),
              readOnly: true,
              maxLines: 1,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  AppAssets.location,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    context.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              onTap: () async {
                final result = await context.pushNamed(
                  Routes.newAddressMap,
                  arguments: NewAddressMapArgs(
                    forAddingAddress: false,
                    address:
                        widget.existingAddress ??
                        AddressModel(
                          id: null,
                          label: _addressNameController.text.trim(),
                          details: _addressController.text.trim(),
                          lat: _lat,
                          lng: _lng,
                        ),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  final newAddressName = result['address'] as String;
                  final newLat = result['lat'] as double;
                  final newLng = result['lng'] as double;
                  setState(() {
                    _addressController.text = newAddressName;
                    _lat = newLat;
                    _lng = newLng;
                  });
                }
              },
            ),
            SizedBox(height: height * 0.03),

            _buildSectionLabel(
              LocaleKeys.address_address_name_label.tr(),
              isRequired: true,
            ),
            SizedBox(height: height * 0.01),
            CustomTextFormField(
              controller: _addressNameController,
              label: LocaleKeys.address_address_name_label.tr(),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  AppAssets.location,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    context.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.03),

            _buildSectionLabel(LocaleKeys.address_access_notes_label.tr()),
            SizedBox(height: height * 0.01),
            CustomTextFormField(
              controller: _accessNotesController,
              label: LocaleKeys.address_access_notes_label.tr(),
              keyboardType: TextInputType.multiline,
              minLines: 3,
            ),
            SizedBox(height: height * 0.04),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: widget.existingAddress == null
                        ? LocaleKeys.address_save_address.tr()
                        : LocaleKeys.profile_save_changes.tr(),
                    onPressed: () {
                      if (_addressNameController.text.trim().isEmpty) return;

                      final newAddress = AddressModel(
                        id: widget.existingAddress?.id,
                        label: _addressNameController.text.trim(),
                        arrivalNotes: _accessNotesController.text.trim(),
                        details: _addressController.text.trim(),
                        lat: _lat,
                        lng: _lng,
                      );

                      if (widget.existingAddress == null) {
                        context.read<AddressesCubit>().addAddress(newAddress);
                      } else {
                        context.read<AddressesCubit>().updateAddress(
                          newAddress,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    onPressed: () => Navigator.pop(context),
                    text: LocaleKeys.cancel.tr(),
                    color: Colors.transparent,
                    textColor: context.colors.textPrimary,
                    borderColor: context.colors.borderSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        if (isRequired)
          Text(
            '*',
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.error,
            ),
          ),
      ],
    );
  }
}
