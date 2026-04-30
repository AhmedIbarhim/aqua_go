import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../data/models/booking_model.dart';
import '../widgets/bookings_list_view.dart';
import '../widgets/bookings_tabs.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  int _selectedIndex = 0;

  final List<BookingModel> dummyBookings = [
    const BookingModel(
      id: '1234',
      title: 'غسلة (داخلي و خارجي). #1234',
      location: 'شارع احمد عبد الخالق, نجران السعودية',
      formattedDateTime: '9:00 م . 4/22/2026',
      totalAmount: 122.00,
      isUpcoming: true,
    ),
    const BookingModel(
      id: '1235',
      title: 'التلميع الداخلي. #1235',
      location: 'شارع الملك فهد, الرياض السعودية',
      formattedDateTime: '4:00 م . 4/25/2026',
      totalAmount: 150.00,
      isUpcoming: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            BookingsTabs(
              selectedIndex: _selectedIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            const SizedBox(height: 16),

            Expanded(child: BookingsListView(bookings: dummyBookings)),
          ],
        ),
      ),
    );
  }
}
