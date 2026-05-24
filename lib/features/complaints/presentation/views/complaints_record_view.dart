import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/complaint_model.dart';
import '../widgets/complaint_record_card.dart';

class ComplaintsRecordView extends StatefulWidget {
  const ComplaintsRecordView({super.key});

  @override
  State<ComplaintsRecordView> createState() => _ComplaintsRecordViewState();
}

class _ComplaintsRecordViewState extends State<ComplaintsRecordView> {
  // Mock data representing the 4 complaints from the Figma design
  final List<ComplaintModel> _complaints = [
    const ComplaintModel(
      id: '12344',
      dateAr: '10 اكتوبر 2024',
      dateEn: '10 October 2024',
      timeAr: '8:00 م',
      timeEn: '8:00 PM',
      status: ComplaintStatus.open,
      bookingId: '9875',
      detailsAr:
          'تأخر الفني في الوصول لأكثر من 30 دقيقة عن الموعد المحدد دون إشعار مسبق.',
      detailsEn:
          'The biker was delayed for more than 30 minutes past the scheduled time without notice.',
    ),
    const ComplaintModel(
      id: '12344',
      dateAr: '10 اكتوبر 2024',
      dateEn: '10 October 2024',
      timeAr: '8:00 م',
      timeEn: '8:00 PM',
      status: ComplaintStatus.closed,
      bookingId: '9654',
      detailsAr:
          'الخدمة لم تكتمل بالشكل المطلوب وهناك بقع تنظيف واضحة على الزجاج الأمامي.',
      detailsEn:
          'The service was incomplete, there are visible water spots left on the front windshield.',
    ),
    const ComplaintModel(
      id: '12344',
      dateAr: '20 ديسمبر 2024',
      dateEn: '20 December 2024',
      timeAr: '8:00 م',
      timeEn: '8:00 PM',
      status: ComplaintStatus.resolved,
      bookingId: '9541',
      detailsAr:
          'تم تعويضي بالكامل لحل مشكلة التأخير، ومستوى استجابة الدعم الفني كان ممتازاً وسريعاً.',
      detailsEn:
          'I was fully compensated for the delay. The customer service support was extremely fast and helpful.',
    ),
    const ComplaintModel(
      id: '12344',
      dateAr: '10 اكتوبر 2024',
      dateEn: '10 October 2024',
      timeAr: '8:00 م',
      timeEn: '8:00 PM',
      status: ComplaintStatus.pending,
      bookingId: '9422',
      detailsAr:
          'تم سحب المبلغ مرتين من البطاقة الائتمانية أثناء تأكيد الحجز وجار التحقق من البنك.',
      detailsEn:
          'The amount was charged twice on my credit card during booking confirmation. Currently under investigation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    // Responsive scaling helpers matching support_view
    double sw(double width) => (width / 414) * screenWidth;
    double sh(double height) => (height / 896) * screenHeight;

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_complaint_log.tr(),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: sh(16)),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw(24)),
                  topRight: Radius.circular(sw(24)),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: sw(24),
                vertical: sh(24),
              ),
              child: _complaints.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _complaints.length,
                      separatorBuilder: (_, __) => SizedBox(height: sh(12)),
                      itemBuilder: (context, index) {
                        final complaint = _complaints[index];
                        return ComplaintRecordCard(
                          complaint: complaint,
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: context.colors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKeys.notifications_no_notifications
                .tr(), // generic empty state
            style: AppTextStyles.medium16.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
