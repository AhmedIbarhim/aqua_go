import 'package:flutter/material.dart';
import '../../../booking/presentation/views/bookings_view.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../my_cars/presentation/views/my_cars_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../widgets/main_navigation_bar.dart';
import '../widgets/main_app_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const MyCarsView(),
    const BookingsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _currentIndex == 0 ? true : false,
      appBar: _currentIndex == 3 ? null : const MainAppBar(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      extendBody: true,
    );
  }
}
