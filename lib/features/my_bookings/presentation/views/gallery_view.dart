import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_network_image.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class GalleryArgs {
  final List<String> images;
  final int initialIndex;
  GalleryArgs({required this.images, this.initialIndex = 0});
}

class GalleryView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryView({super.key, required this.images, this.initialIndex = 0});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late PageController _pageController;
  late int _currentIndex;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImageLabel(int index) {
    if (index == 0) {
      return LocaleKeys.bookings_before_washing.tr();
    } else {
      return LocaleKeys.bookings_after_washing.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.cardBackGround,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: _currentScale > 1.0
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        itemCount: widget.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildImageSection(index, context),
                          );
                        },
                      ),
                    ),
                    _buildThumbnails(),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildImageSection(int index, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 5.0,
              minScale: 1.0,
              onInteractionUpdate: (details) {
                if (details.scale != _currentScale) {
                  setState(() {
                    _currentScale = details.scale;
                  });
                }
              },
              onInteractionEnd: (details) {
                if (_currentScale < 1.1) {
                  setState(() {
                    _currentScale = 1.0;
                  });
                }
              },
              child: CustomNetworkImage(
                widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getImageLabel(index),
          textAlign: TextAlign.center,
          style: AppTextStyles.regular18.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              LocaleKeys.bookings_photo_gallery.tr(),
              style: AppTextStyles.regular18.copyWith(
                color: context.colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              AppAssets.close,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                context.colors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnails() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.images.length, (index) {
            final isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 136,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: context.colors.primary, width: 2)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomNetworkImage(
                    widget.images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
