import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../generated/locale_keys.g.dart';
import 'complain_image_field.dart';

class ComplainImagesSection extends StatefulWidget {
  const ComplainImagesSection({super.key});

  @override
  State<ComplainImagesSection> createState() => _ComplainImagesSectionState();
}

class _ComplainImagesSectionState extends State<ComplainImagesSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<File?> images = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.bookings_car_images.tr(),
              style: AppTextStyles.medium16,
            ),
          ],
        ),
        const SizedBox(height: 8),
        images.isEmpty
            ? DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(8),
                  dashPattern: [8, 4],
                  strokeWidth: 2,
                  color: context.colors.contentDisabled,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePickerHelper.pickImage();
                    if (pickedFile != null) {
                      setState(() {
                        images.add(pickedFile);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 0.15,
                    color: context.colors.brandSubtle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.addImage),
                        Text(
                          LocaleKeys.bookings_upload_images.tr(),
                          style: AppTextStyles.medium14,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: images.length < 4 ? images.length + 1 : 4,

                  itemBuilder: (context, index) {
                    return ComplainImageField(
                      initialImage: index < images.length
                          ? images[index]
                          : null,
                      onFileChanged: (image) {
                        if (index < images.length) {
                          if (image == null) {
                            images.removeAt(index);
                          } else {
                            images[index] = image;
                          }
                        } else {
                          if (image != null) {
                            images.add(image);
                          }
                        }
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
      ],
    );
  }
}
