import 'package:aqua_go/features/booking/presentation/controllers/booking_cubit.dart';
import 'package:aqua_go/features/home/data/models/add_on_model.dart';
import 'package:flutter_test/flutter_test.dart';

AddOnModel addon(String? id, {int priceMinor = 500}) =>
    AddOnModel(id: id, nameAr: 'ar', nameEn: 'en', priceMinor: priceMinor);

void main() {
  group('remapAddonSelections', () {
    test('same list -> indices unchanged', () {
      final addons = [addon('a'), addon('b'), addon('c')];
      expect(remapAddonSelections(addons, {0, 2}, addons), {0, 2});
    });

    test('reordered fresh list -> indices follow the add-on ids', () {
      final old = [addon('a'), addon('b'), addon('c')];
      final fresh = [addon('c'), addon('a'), addon('b')];
      expect(remapAddonSelections(old, {0, 2}, fresh), {1, 0});
    });

    test('selected add-on removed from catalogue -> selection dropped', () {
      final old = [addon('a'), addon('b'), addon('c')];
      final fresh = [addon('a'), addon('c')]; // 'b' deactivated by admin
      expect(remapAddonSelections(old, {1, 2}, fresh), {1});
    });

    test('out-of-range or id-less old selections are dropped safely', () {
      final old = [addon('a'), addon(null)];
      final fresh = [addon('a')];
      expect(remapAddonSelections(old, {0, 1, 7}, fresh), {0});
    });

    test('empty selections -> empty result', () {
      final old = [addon('a')];
      final fresh = [addon('a'), addon('b')];
      expect(remapAddonSelections(old, <int>{}, fresh), isEmpty);
    });
  });
}
