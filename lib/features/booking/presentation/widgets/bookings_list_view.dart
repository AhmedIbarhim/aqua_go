import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart';
import 'booking_card.dart';

class BookingsListView extends StatelessWidget {
  const BookingsListView({super.key, required this.bookings});

  final List<BookingModel> bookings;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return BookingCard(booking: bookings[index]);
      },
    );
  }
}
