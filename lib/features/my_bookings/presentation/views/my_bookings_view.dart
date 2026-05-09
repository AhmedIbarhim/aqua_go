import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../data/models/my_bookings_model.dart';
import '../widgets/my_bookings_list_view.dart';
import '../widgets/my_bookings_tabs.dart';

class MyBookingsView extends StatefulWidget {
  const MyBookingsView({super.key});

  @override
  State<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> {
  int _selectedIndex = 0;

  final List<MyBookingsModel> dummyBookings = [
    const MyBookingsModel(
      id: '1234',
      title: 'غسلة (داخلي و خارجي). #1234',
      location: 'شارع احمد عبد الخالق, نجران السعودية',
      formattedDateTime: '9:00 م . 4/22/2026',
      totalAmount: 122.00,
      isUpcoming: true,
      latitude: 24.7136,
      longitude: 46.6753,
    ),
    const MyBookingsModel(
      id: '1235',
      title: 'التلميع الداخلي. #1235',
      location: 'شارع الملك فهد, الرياض السعودية',
      formattedDateTime: '4:00 م . 4/25/2026',
      totalAmount: 150.00,
      isUpcoming: true,
      latitude: 24.7136,
      longitude: 46.6753,
    ),
    const MyBookingsModel(
      id: '1235',
      title: 'التلميع الداخلي. #1235',
      location:
          'شارع الملك فهد, الرياض السعودdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddية',
      formattedDateTime: '4:00 م . 4/25/2026',
      totalAmount: 150.00,
      isUpcoming: true,
      latitude: 24.7136,
      longitude: 46.6753,
    ),
    const MyBookingsModel(
      id: '1235',
      title: 'التلميع الداخلي. #1235',
      location: 'شارع الملك فهد, الرياض السعودية',
      formattedDateTime: '4:00 م . 4/25/2026',
      totalAmount: 150.00,
      isUpcoming: false,
      latitude: 24.7136,
      longitude: 46.6753,
    ),
    const MyBookingsModel(
      id: '1235',
      title: 'التلميع الداخلي. #1235',
      location: 'شارع الملك فهد, الرياض السعودية',
      formattedDateTime: '4:00 م . 4/25/2026',
      totalAmount: 150.00,
      isUpcoming: false,
      latitude: 24.7136,
      longitude: 46.6753,
    ),
    const MyBookingsModel(
      id: '1235',
      title: 'التلميع الداخلي. #1235',
      location:
          'شارع الملك فهد,hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh الرياض السعودية',
      formattedDateTime: '4:00 م . 4/25/2026',
      totalAmount: 150.00,
      isUpcoming: false,
      latitude: 24.7136,
      longitude: 46.6753,
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
            MyBookingsTabs(
              selectedIndex: _selectedIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: MyBookingsListView(
                bookings: dummyBookings
                    .where(
                      (booking) => _selectedIndex == 0
                          ? booking.isUpcoming
                          : !booking.isUpcoming,
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
