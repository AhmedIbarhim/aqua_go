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
      final filteredGifts = state.gifts
          .where((gift) => _selectedIndex == 0 ? gift.isSent : !gift.isSent)
          .toList();

      if (filteredGifts.isEmpty) {
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

      return RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async {
          await context.read<GiftsCubit>().fetchGifts(isRefresh: true);
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              context.read<GiftsCubit>().loadMoreGifts();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: filteredGifts.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final gift = filteredGifts[index];
              if (_selectedIndex == 0) {
                return SentGiftCard(gift: gift);
              } else {
                return ReceivedGiftCard(
                  gift: gift,
                  onRedeemPressed: () async {
                    if (gift.code != null) {
                      final ok = await context.read<GiftsCubit>().redeemGift(
                        gift.code!,
                      );
                      if (context.mounted) {
                        if (ok) {
                          context.showSuccessSnackBar(
                            LocaleKeys.gifts_redeem_success.tr(
                              context: context,
                            ),
                          );
                        } else {
                          context.showErrorSnackBar(
                            LocaleKeys.gifts_redeem_failed.tr(context: context),
                          );
                        }
                      }
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

    final hasSentGifts = state.gifts.any((gift) => gift.isSent);
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
          postWidget: Icon(Icons.add),
        ),
      ),
    );
  }
}
