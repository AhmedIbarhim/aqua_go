import 'package:easy_localization/easy_localization.dart';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';

class ReceiptNumberCard extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptNumberCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return ClipRRect(
      borderRadius: BorderRadius.circular(sw(20)),
      child: Container(
        height: sh(110),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(sw(20)),
        ),
        child: Stack(
          children: [
            // Green "Paid" Corner Ribbon (Top-Left)
            Positioned(
              left: context.isAr ? 0 : null,
              right: context.isAr ? null : 0,
              top: 0,
              child: CustomPaint(
                size: Size(sw(75), sw(75)),
                painter: _TrianglePainter(
                  color: context.colors.successSecondry,
                  isAr: context.isAr,
                ),
              ),
            ),
            Positioned(
              left: context.isAr ? sw(8) : null,
              right: context.isAr ? null : sw(8),
              top: sw(20),
              child: Transform.rotate(
                angle: context.isAr ? -pi / 4 : pi / 4,
                child: Text(
                  LocaleKeys.receipt_paid.tr(context: context),
                  style: AppTextStyles.bold13.copyWith(color: Colors.black),
                ),
              ),
            ),
            // Invoice Number Text
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: sw(24),
                top: sh(18),
                bottom: sh(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.receipt_invoice_number.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: sh(6)),
                  Text(
                    '#${booking.referenceNumber ?? ''}',
                    style: AppTextStyles.medium24.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isAr;

  _TrianglePainter({required this.color, required this.isAr});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    if (isAr) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
