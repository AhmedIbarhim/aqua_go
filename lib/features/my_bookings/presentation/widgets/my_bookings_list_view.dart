import 'package:flutter/material.dart';
import '../../data/models/booking_summary_model.dart';
import 'my_bookings_card.dart';

class MyBookingsListView extends StatelessWidget {
  const MyBookingsListView({super.key, required this.bookings});

  final List<BookingSummaryModel> bookings;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // AlwaysScrollable so the RefreshIndicator can pull even when the list is
      // short (doesn't fill the viewport) — otherwise the gesture never fires.
      physics: const AlwaysScrollableScrollPhysics(),
      // Bottom padding so the last card clears the floating bottom nav bar.
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return MyBookingsCard(booking: bookings[index]);
      },
    );
  }
}
