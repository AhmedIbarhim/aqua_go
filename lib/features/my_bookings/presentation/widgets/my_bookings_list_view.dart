import 'package:flutter/material.dart';
import '../../data/models/booking_response_model.dart';
import 'my_bookings_card.dart';

class MyBookingsListView extends StatelessWidget {
  const MyBookingsListView({super.key, required this.bookings});

  final List<BookingResponseModel> bookings;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return MyBookingsCard(booking: bookings[index]);
      },
    );
  }
}
