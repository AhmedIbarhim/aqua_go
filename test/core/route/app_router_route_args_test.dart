import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Routes.offers builds a route when no arguments are supplied', () {
    final route = AppRouter.generateRoute(
      const RouteSettings(name: Routes.offers),
    );
    expect(route, isA<MaterialPageRoute>());
  });

  test('Routes.offers still builds when arguments are an explicit null', () {
    final route = AppRouter.generateRoute(
      const RouteSettings(name: Routes.offers, arguments: null),
    );
    expect(route, isA<MaterialPageRoute>());
  });

  test('Routes.packageDetail builds a route from PackageDetailArgs', () {
    final route = AppRouter.generateRoute(
      RouteSettings(
        name: Routes.packageDetail,
        arguments: PackageDetailArgs(
          packageId: '11111111-1111-1111-1111-111111111111',
        ),
      ),
    );
    expect(route, isA<MaterialPageRoute>());
  });

  test('Routes.packageDetail rejects a non-PackageDetailArgs argument, proving '
      'it is wired and not falling through to the Placeholder default', () {
    expect(
      () => AppRouter.generateRoute(
        const RouteSettings(name: Routes.packageDetail, arguments: 42),
      ),
      throwsA(isA<TypeError>()),
    );
  });
}
