import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../home/presentation/views/home_view.dart';
import '../widgets/bottom_navigation_bar.dart';
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
    Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.background,
      child: const Center(child: Text('My Cars Page')),
    ),
    Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.background,
      child: const Center(child: Text('Reservations Page')),
    ),
    Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.background,
      child: const Center(child: Text('Profile Page')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? const MainAppBar() : null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigationBar(
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
