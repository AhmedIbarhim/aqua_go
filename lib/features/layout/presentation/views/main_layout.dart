import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../my_bookings/presentation/views/my_bookings_view.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../my_cars/presentation/views/my_cars_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../widgets/main_navigation_bar.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/lazy_indexed_stack.dart';

class MainLayoutArgs {
  final int initialIndex;
  final String? routeName;
  final Object? arguments;
  MainLayoutArgs({this.initialIndex = 0, this.routeName, this.arguments});
}

class MainLayout extends StatefulWidget {
  final MainLayoutArgs? args;
  const MainLayout({super.key, this.args});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  DateTime? _lastPressed;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.args?.initialIndex ?? 0;
  }

  void changeIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  static const List<Widget> _pageBuilders = [
    HomeView(),
    MyCarsView(),
    MyBookingsView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          context.showWarningSnackBar(
            LocaleKeys.snackbar_double_tap_to_exit.tr(context: context),
            duration: const Duration(seconds: 2),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
                unloadableIndices: const [2], // 2 represents MyBookingsView
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
      ),
    );
  }
}
