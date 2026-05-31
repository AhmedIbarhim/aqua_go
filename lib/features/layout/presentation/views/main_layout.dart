import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../my_bookings/presentation/views/my_bookings_view.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../my_cars/presentation/views/my_cars_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../widgets/main_navigation_bar.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/lazy_indexed_stack.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  static const List<Widget> _pageBuilders = [
    HomeView(),
    MyCarsView(),
    MyBookingsView(),
    ProfileView(),
  ];

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
            body: LazyIndexedStack(
              index: _currentIndex,
              children: List.generate(
                _pageBuilders.length,
                (i) => _pageBuilders[i],
              ),
            ),
            bottomNavigationBar: MainNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
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
