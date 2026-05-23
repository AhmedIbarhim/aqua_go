import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/controllers/connectivity_controller/connectivity_cubit.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final offlineText = context.isAr
        ? 'لا يوجد اتصال بالإنترنت حالياً'
        : 'No internet connection';

    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isOffline = !state.isConnected;

        return AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Material(
            elevation: 4,
            color: context.colors.themeOpositeColor.withValues(alpha: 0.5),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: context.colors.themeColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      offlineText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.themeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          crossFadeState: isOffline
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        );
      },
    );
  }
}
