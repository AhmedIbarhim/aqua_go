import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/points_transaction_model.dart';
import '../widgets/points_balance_card.dart';
import '../widgets/points_history_section.dart';

class MyWalletView extends StatefulWidget {
  const MyWalletView({super.key});

  @override
  State<MyWalletView> createState() => _MyWalletViewState();
}

class _MyWalletViewState extends State<MyWalletView> {
  late final List<PointsTransactionModel> _mockTransactions;
  final int _totalPoints = 1250;
  final double _equivalentValue = 12.5;
  final int _earnRateRiyals = 10;
  final int _conversionPoints = 100;
  final double _conversionRiyals = 1.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Create dates dynamically relative to current time to correctly group under Today, Yesterday, etc.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 20, 0);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    _mockTransactions = [
      PointsTransactionModel(
        id: '1',
        bookingId: '1522',
        points: 20,
        date: today,
        isEarned: true,
      ),
      PointsTransactionModel(
        id: '2',
        bookingId: '1522',
        points: 25,
        date: today.subtract(const Duration(minutes: 30)),
        isEarned: false,
      ),
      PointsTransactionModel(
        id: '3',
        bookingId: '1522',
        points: 50,
        date: yesterday,
        isEarned: true,
      ),
      PointsTransactionModel(
        id: '4',
        bookingId: '1522',
        points: 25,
        date: yesterday.subtract(const Duration(hours: 1)),
        isEarned: true,
      ),
      PointsTransactionModel(
        id: '5',
        bookingId: '1522',
        points: 15,
        date: twoDaysAgo,
        isEarned: true,
      ),
      PointsTransactionModel(
        id: '6',
        bookingId: '1522',
        points: 10,
        date: twoDaysAgo.subtract(const Duration(hours: 2)),
        isEarned: false,
      ),
    ];

    _loadData();
  }

  void _loadData() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
        child: Skeletonizer(
          enabled: _isLoading,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: sw(24), vertical: sh(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Points Balance Card Widget
                PointsBalanceCard(
                  points: _totalPoints,
                  equivalentValue: _equivalentValue,
                  earnRateRiyals: _earnRateRiyals,
                  conversionPoints: _conversionPoints,
                  conversionRiyals: _conversionRiyals,
                ),

                SizedBox(height: sh(28)),

                // Points History Section Widget
                PointsHistorySection(transactions: _mockTransactions),

                // Bottom padding
                SizedBox(height: sh(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
