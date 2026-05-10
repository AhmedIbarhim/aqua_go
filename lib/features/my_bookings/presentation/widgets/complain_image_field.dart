import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../generated/locale_keys.g.dart';

class ComplainImageField extends StatefulWidget {
  const ComplainImageField({
    super.key,
    required this.onFileChanged,
    this.initialImage,
  });

  final ValueChanged<File?> onFileChanged;
  final File? initialImage;

  @override
  State<ComplainImageField> createState() => _ComplainImageFieldState();
}

class _ComplainImageFieldState extends State<ComplainImageField> {
  bool isLoading = false;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    imageFile = widget.initialImage;
  }

  @override
  void didUpdateWidget(covariant ComplainImageField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != oldWidget.initialImage) {
      imageFile = widget.initialImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          try {
            final pickedFile = await ImagePickerHelper.pickWithCamera();
            if (pickedFile != null) {
              imageFile = pickedFile;
              widget.onFileChanged(imageFile);
              setState(() {});
            }
          } on Exception catch (e) {
            log(
              "==============================================error in pickImage $e",
            );
            setState(() {
              isLoading = false;
            });
          }

          setState(() {
            isLoading = false;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(8),
                  dashPattern: [8, 4],
                  strokeWidth: 2,
                  color: context.colors.contentDisabled,
                ),
                child: Container(
                  height: MediaQuery.sizeOf(context).width * 0.2,
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  color: context.colors.brandSubtle,
                  child: imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            imageFile!,
                            fit: BoxFit.cover,
                            height: MediaQuery.sizeOf(context).width * 0.2,
                            width: MediaQuery.sizeOf(context).width * 0.2,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.addImage,
                              colorFilter: ColorFilter.mode(
                                context.colors.contentDisabled,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocaleKeys.bookings_add_image.tr(),
                              style: AppTextStyles.medium12,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Visibility(
                visible: imageFile != null,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imageFile = null;

                      widget.onFileChanged(null);
                    });
                  },
                  child: CircleAvatar(
                    radius: 10,

                    backgroundColor: Colors.white,
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: Icon(Icons.close, color: Colors.red, size: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
