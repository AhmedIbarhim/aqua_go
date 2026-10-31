import '../../../home/data/models/add_on_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../subscriptions/data/models/subscription_response_model/subscription_included_allowance.dart';
import '../../../subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import '../../../subscriptions/data/models/subscription_response_model/subscription_wash.dart';

const _includedKind = 'included';
const _optionalKind = 'optional';

/// What the booking flow needs from a subscription: the wash being booked and
/// its package expressed as a [ServiceModel].
class SubscriptionCatalog {
  const SubscriptionCatalog({
    required this.service,
    required this.washId,
    required this.includedAddonIds,
    required this.optionalAddonIds,
  });

  final ServiceModel service;

  final String washId;

  final Set<String> includedAddonIds;

  final Set<String> optionalAddonIds;
}

/// Returns null when the subscription has no wash that can be booked.
SubscriptionCatalog? subscriptionCatalogFrom(
  SubscriptionResponseModel subscription, {
  String? preferredWashId,
}) {
  final wash = _pickWash(subscription.washes, preferredWashId);
  if (wash == null) return null;

  final includedAddons = _includedAddons(subscription);
  final optionalAddons = _optionalAddons(subscription, wash);

  return SubscriptionCatalog(
    service: ServiceModel(
      id: subscription.packageId,
      code: '',
      rawName: ServiceName(
        nameAr: subscription.packageInfo.nameAr,
        nameEn: subscription.packageInfo.nameEn,
      ),
      rawDescription: const ServiceDescription(descAr: '', descEn: ''),
      active: true,
      addons: [...includedAddons, ...optionalAddons],
    ),
    washId: wash.washId,
    includedAddonIds: _idsOf(includedAddons),
    optionalAddonIds: _idsOf(optionalAddons),
  );
}

SubscriptionWash? _pickWash(
  List<SubscriptionWash> washes,
  String? preferredWashId,
) =>
    washes.where((w) => w.washId == preferredWashId).firstOrNull ??
    washes.where((w) => w.canSchedule).firstOrNull;

/// Included addons come with price data for when the free quantity runs out.
List<AddOnModel> _includedAddons(SubscriptionResponseModel subscription) {
  return subscription.packageInfo.includedAddons.map((a) {
    final allowance = subscription.includedAllowances.firstWhere(
      (allow) => allow.addonId == a.id,
      orElse: () => SubscriptionIncludedAllowance(
        addonId: a.id ?? '',
        totalQty: a.freeQty ?? 0,
        consumedQty: 0,
        remainingQty: a.freeQty ?? 0,
      ),
    );

    return AddOnModel(
      id: a.id,
      nameAr: a.nameAr,
      nameEn: a.nameEn,
      priceMinor: allowance.remainingQty > 0 ? 0 : a.priceMinor,
      currency: a.currency,
      imageUrl: a.imageUrl,
      freeQty: allowance.remainingQty,
      maxQtyPerWash: a.maxQtyPerWash ?? allowance.totalQty,
      qty: allowance.consumedQty,
      kind: _includedKind,
    );
  }).toList();
}

/// Optional addons are always paid. Prefers packageInfo, falls back to the wash.
List<AddOnModel> _optionalAddons(
  SubscriptionResponseModel subscription,
  SubscriptionWash wash,
) {
  final packageOptional = subscription.packageInfo.optionalAddons;
  final rawOptional = packageOptional.isNotEmpty
      ? packageOptional
      : wash.availableOptionalAddons;

  return rawOptional
      .map(
        (a) => AddOnModel(
          id: a.id,
          nameAr: a.nameAr,
          nameEn: a.nameEn,
          priceMinor: a.priceMinor,
          currency: a.currency,
          imageUrl: a.imageUrl,
          kind: _optionalKind,
        ),
      )
      .toList();
}

Set<String> _idsOf(List<AddOnModel> addons) =>
    addons.map((a) => a.id).whereType<String>().toSet();
