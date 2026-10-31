import '../../home/data/models/add_on_model.dart';

Set<int> remapAddonSelections(
  List<AddOnModel> oldAddons,
  Set<int> selectedIndices,
  List<AddOnModel> freshAddons,
) {
  final remapped = <int>{};
  for (final idx in selectedIndices) {
    if (idx < 0 || idx >= oldAddons.length) continue;
    final id = oldAddons[idx].id;
    if (id == null) continue;
    final newIdx = freshAddons.indexWhere((a) => a.id == id);
    if (newIdx != -1) remapped.add(newIdx);
  }
  return remapped;
}
