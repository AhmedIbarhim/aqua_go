import 'package:aqua_go/core/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/guest_placeholder_widget.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/config/session/session_state.dart';
import '../controllers/gifts_cubit.dart';
import '../controllers/gifts_state.dart';
import '../widgets/empty_gifts_widgets.dart';
import '../widgets/gifts_tabs.dart';
import '../widgets/sent_gift_card.dart';
import '../widgets/received_gift_card.dart';
import '../../../booking/domain/strategies/redeem_gift_booking_submit.dart';
import '../../../booking/domain/configs/booking_flow_config.dart';
import '../../../../core/route/app_router.dart';
import '../../../home/data/models/service_model.dart';

class GiftsView extends StatefulWidget {
  const GiftsView({super.key});

  @override
  State<GiftsView> createState() => _GiftsViewState();
}

class _GiftsViewState extends State<GiftsView> {
  int _selectedIndex = 0; // 0: Sent Gifts, 1: Received Gifts

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, _) {
        if (user == null) {
          return Scaffold(
            backgroundColor: context.colors.screenBG,
            appBar: GenericAppBar(
              title: LocaleKeys.gifts_title.tr(context: context),
              automaticallyImplyLeading: true,
            ),
            body: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: GuestPlaceholderWidget(
                titleEn: "Your Gifts",
                titleAr: "هداياك",
                descEn:
                    "Please log in to track and view your sent and received gifts.",
                descAr:
                    "يرجى تسجيل الدخول لمتابعة وعرض هداياك المرسلة والمستلمة.",
              ),
            ),
          );
        }

        return BlocProvider(
          create: (context) => locator<GiftsCubit>()..fetchGifts(),
          child: BlocBuilder<GiftsCubit, GiftsState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: context.colors.screenBG,
                appBar: GenericAppBar(
                  title: LocaleKeys.gifts_title.tr(context: context),
                  automaticallyImplyLeading: true,
                ),
                body: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      GiftsTabs(
                        selectedIndex: _selectedIndex,
                        onTabChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildGiftsContent(context, state)),
                    ],
                  ),
                ),
                bottomNavigationBar: _buildBottomButton(context, state),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGiftsContent(BuildContext context, GiftsState state) {
    if (state is GiftsLoading || state is GiftsInitial) {
      return const Center(child: CustomLoadingIndicator(size: 80));
    } else if (state is GiftsFailure) {
      return ErrorRetryWidget(
        errorMessage: state.errMessage,
        onRetry: () => context.read<GiftsCubit>().fetchGifts(),
      );
    } else if (state is GiftsSuccess) {
      final isEmpty = _selectedIndex == 0
          ? state.sentGifts.isEmpty
          : state.receivedGifts.isEmpty;

      if (isEmpty) {
        return RefreshIndicator(
          color: context.colors.primary,
          onRefresh: () async {
            await context.read<GiftsCubit>().fetchGifts(isRefresh: true);
          },
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: EmptyGiftsWidget(
                  isSentTab: _selectedIndex == 0,
                  onSendGiftPressed: () {
                    Navigator.pushNamed(context, Routes.sendGift).then((val) {
                      if (val == true && context.mounted) {
                        context.read<GiftsCubit>().fetchGifts(isRefresh: true);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        );
      }

      final itemCount = _selectedIndex == 0
          ? state.sentGifts.length
          : state.receivedGifts.length;

      return RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async {
          await context.read<GiftsCubit>().fetchGifts(isRefresh: true);
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              context.read<GiftsCubit>().loadMoreGifts(
                tabIndex: _selectedIndex,
              );
            }
            return false;
          },
          child: ListView.builder(
            itemCount: itemCount,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (_selectedIndex == 0) {
                final gift = state.sentGifts[index];
                return SentGiftCard(gift: gift);
              } else {
                final gift = state.receivedGifts[index];
                return ReceivedGiftCard(
                  gift: gift,
                  onRedeemPressed: () {
                    if (gift.giftCode.isNotEmpty) {
                      Navigator.of(context).pushNamed(
                        Routes.bookingLocation,
                        arguments: BookingFlowStartArgs(
                          service:
                              gift.service ??
                              ServiceModel(
                                id: gift.serviceId ?? '',
                                rawName: ServiceName(
                                  nameAr: gift.serviceName.ar,
                                  nameEn: gift.serviceName.en,
                                ),
                              ),
                          giftCode: gift.giftCode,
                          flowConfig: const BookingFlowConfig(
                            flowType: BookingFlowType.giftRedeem,
                          ),
                          submitStrategy: const RedeemGiftBookingSubmit(),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget? _buildBottomButton(BuildContext context, GiftsState state) {
    if (_selectedIndex != 0) return null;
    if (state is! GiftsSuccess) return null;

    final hasSentGifts = state.sentGifts.isNotEmpty;
    if (!hasSentGifts) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: CustomButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.sendGift).then((val) {
              if (val == true && context.mounted) {
                context.read<GiftsCubit>().fetchGifts(isRefresh: true);
              }
            });
          },
          text: LocaleKeys.gifts_empty_send_now.tr(context: context),
          postWidget: const Icon(Icons.add),
        ),
      ),
    );
  }
}
