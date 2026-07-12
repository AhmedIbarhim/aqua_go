import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/points_transaction_model.dart';
import 'points_transaction_tile.dart';

class PointsHistorySection extends StatelessWidget {
  final List<PointsTransactionModel> transactions;

  const PointsHistorySection({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    double sh(double height) => context.sh(height);

    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group transactions by date category (Today, Yesterday, DateString)
    final grouped = _groupTransactions(context, transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: سجل النقاط
        Text(
          LocaleKeys.wallet_history.tr(context: context),
          style: AppTextStyles.semiBold18.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: sh(16)),
        // Grouped Lists
        ...grouped.entries.map((entry) {
          final groupHeader = entry.key;
          final groupTransactions = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header: اليوم / امس / 18 ابريل 2026
              Padding(
                padding: EdgeInsets.only(
                  bottom: sh(12),
                  top: sh(8),
                ),
                child: Text(
                  groupHeader,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              // List of transactions for this date
              ...groupTransactions.map((tx) => PointsTransactionTile(transaction: tx)),
            ],
          );
        }),
      ],
    );
  }

  Map<String, List<PointsTransactionModel>> _groupTransactions(
    BuildContext context,
    List<PointsTransactionModel> txs,
  ) {
    final Map<String, List<PointsTransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final locale = context.locale.toString();

    // Sort transactions by date descending to ensure correct order
    final sortedTxs = List<PointsTransactionModel>.from(txs)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final tx in sortedTxs) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String groupKey;

      if (txDate == today) {
        groupKey = LocaleKeys.wallet_today.tr(context: context);
      } else if (txDate == yesterday) {
        groupKey = LocaleKeys.wallet_yesterday.tr(context: context);
      } else {
        groupKey = DateFormat('d MMMM yyyy', locale).format(tx.date);
      }

      if (!groups.containsKey(groupKey)) {
        groups[groupKey] = [];
      }
      groups[groupKey]!.add(tx);
    }

    return groups;
  }
}
