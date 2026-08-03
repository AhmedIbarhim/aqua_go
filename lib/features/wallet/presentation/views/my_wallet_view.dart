import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/components/error_retry_widget.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/points_transaction_model.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_history_section.dart';
import '../controllers/wallet_cubit.dart';
import '../controllers/wallet_state.dart';

class MyWalletView extends StatefulWidget {
  const MyWalletView({super.key});

  @override
  State<MyWalletView> createState() => _MyWalletViewState();
}

class _MyWalletViewState extends State<MyWalletView> {
  late final List<PointsTransactionModel> _mockTransactions;
  final int _mockPoints = 1250;
  final double _mockEquivalentValue = 12.5;
  final int _mockEarnRateRiyals = 10;
  final int _mockConversionPoints = 100;
  final double _mockConversionRiyals = 1.0;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 20, 0);

    _mockTransactions = List.generate(
      5,
      (index) => PointsTransactionModel(
        id: index.toString(),
        bookingId: '1522',
        points: 20,
        date: today.subtract(Duration(hours: index)),
        isEarned: index % 2 == 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.wallet_title.tr(context: context),
        centerTitle: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(sw(24)),
            topRight: Radius.circular(sw(24)),
          ),
        ),
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state is WalletFailure) {
              return ErrorRetryWidget(
                errorMessage: state.errMessage,
                onRetry: () => context.read<WalletCubit>().fetchWallet(),
              );
            }

            final bool isLoading =
                state is WalletLoading || state is WalletInitial;

            // Extract values depending on success state
            final int points;
            final double equivalentValue;
            final int earnRateRiyals;
            final int conversionPoints;
            final double conversionRiyals;
            final List<PointsTransactionModel> transactions;
            final bool hasReachedMax;

            if (state is WalletSuccess) {
              points = state.balanceModel.points;
              equivalentValue = state.balanceModel.estimatedValueMinor / 100.0;

              final earnMinor = state.balanceModel.earnMinorPerPoint;
              earnRateRiyals = earnMinor > 0 ? (earnMinor / 100).round() : 10;

              final redemptionRate =
                  state.balanceModel.redemptionRateMinorPerPoint;
              if (redemptionRate >= 100) {
                conversionPoints = 1;
                conversionRiyals = redemptionRate / 100.0;
              } else if (redemptionRate > 0) {
                conversionPoints = (100 / redemptionRate).round();
                conversionRiyals = 1.0;
              } else {
                conversionPoints = 100;
                conversionRiyals = 1.0;
              }

              transactions = state.transactions;
              hasReachedMax = state.hasReachedMax;
            } else {
              // Loading fallback to mock data
              points = _mockPoints;
              equivalentValue = _mockEquivalentValue;
              earnRateRiyals = _mockEarnRateRiyals;
              conversionPoints = _mockConversionPoints;
              conversionRiyals = _mockConversionRiyals;
              transactions = _mockTransactions;
              hasReachedMax = true;
            }

            return Skeletonizer(
              enabled: isLoading,
              child: RefreshIndicator(
                color: context.colors.primary,
                onRefresh: () async {
                  await context.read<WalletCubit>().fetchWallet(
                    isRefresh: true,
                  );
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      context.read<WalletCubit>().loadMoreTransactions();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: sw(24),
                      vertical: sh(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Points Balance Card Widget
                        PointsBalanceCard(
                          points: points,
                          equivalentValue: equivalentValue,
                          earnRateRiyals: earnRateRiyals,
                          conversionPoints: conversionPoints,
                          conversionRiyals: conversionRiyals,
                        ),

                        SizedBox(height: sh(28)),

                        // Points History Section Widget
                        PointsHistorySection(transactions: transactions),

                        if (!hasReachedMax) ...[
                          SizedBox(height: sh(16)),
                          Center(
                            child: context.watch<WalletCubit>().isLoadingMore
                                ? const CircularProgressIndicator.adaptive()
                                : const SizedBox.shrink(),
                          ),
                        ],

                        // Bottom padding
                        SizedBox(height: sh(40)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
