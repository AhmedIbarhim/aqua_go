import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../my_bookings/presentation/views/my_bookings_view.dart';
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

  /// Pages are built lazily: a tab's widget is only created the first time
  /// it is selected, preventing background API calls on app start.
  static const List<Widget> _pageBuilders = [
    HomeView(),
    MyCarsView(),
    MyBookingsView(),
    ProfileView(),
  ];

  /// Tracks which tab indices have been visited at least once.
  final Set<int> _visitedIndices = {0}; // Home is always shown first

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          if (_currentIndex == 0)
            context.isLightTheme
                ? Image.asset(
                    AppAssets.homeLightHeader,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: height * 0.45,
                  )
                : SizedBox(height: height * 0.45),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _currentIndex == 3 ? null : const MainAppBar(),
            body: IndexedStack(
              index: _currentIndex,
              children: List.generate(
                _pageBuilders.length,
                (i) => _visitedIndices.contains(i)
                    ? _pageBuilders[i]
                    : const SizedBox.shrink(),
              ),
            ),
            bottomNavigationBar: MainNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _visitedIndices.add(index);
                  _currentIndex = index;
                });
              },
            ),
            extendBody: true,
          ),
        ],
      ),
    );
  }
}
