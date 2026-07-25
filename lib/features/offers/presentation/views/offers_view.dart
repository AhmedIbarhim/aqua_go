import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../controllers/offers_controller/offers_cubit.dart';
import '../widgets/offer_card.dart';
import 'offer_detail_view.dart';

/// Optional route arguments for [Routes.offers]. A caller that ALREADY holds
/// the eligible feed can pass it to skip a second round-trip; the home rail's
/// "View more" pushes bare and the screen self-fetches instead.
class OffersArgs {
  final List<CustomerOfferModel> offers;
  OffersArgs({required this.offers});
}

class OffersView extends StatelessWidget {
  const OffersView({super.key, this.offers});

  /// Non-null -> render this list verbatim. Null -> render whatever the
  /// [OffersCubit] provided above this widget emits (the router kicks off
  /// `getOffers()` in that case).
  final List<CustomerOfferModel>? offers;

  @override
  Widget build(BuildContext context) {
    final seeded = offers;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: GenericAppBar(title: LocaleKeys.offers_title.tr(context: context)),
      body: seeded != null ? _list(context, seeded) : _fromCubit(context),
    );
  }

  Widget _fromCubit(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        switch (state) {
          case OffersLoaded(offers: final loaded):
            return RefreshIndicator(
              onRefresh: () => context.read<OffersCubit>().getOffers(),
              child: _list(context, loaded),
            );
          case OffersError():
            return _Message(text: LocaleKeys.offers_error.tr(context: context));
          case OffersInitial():
          case OffersLoading():
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ShimmerHelper.offers(height: height * 0.3),
            );
        }
      },
    );
  }

  Widget _list(BuildContext context, List<CustomerOfferModel> offers) {
    if (offers.isEmpty) {
      // Kept scrollable so the RefreshIndicator above still works when empty.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          _Message(text: LocaleKeys.offers_empty.tr(context: context)),
        ],
      );
    }
    // Defensive: the API already returns endsAt ASC, but this screen owns the
    // ordering the design pins, so it re-sorts locally.
    final sorted = [...offers]..sort((a, b) => a.endsAt.compareTo(b.endsAt));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _openDetail(context, sorted[index]),
        child: OfferCard(offer: sorted[index], atHome: false),
      ),
    );
  }

  void _openDetail(BuildContext context, CustomerOfferModel offer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OfferDetailView(offer: offer)),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
