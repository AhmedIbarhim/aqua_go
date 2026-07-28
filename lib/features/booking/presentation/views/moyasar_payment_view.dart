import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:moyasar/moyasar.dart' as moyasar;

import 'package:aqua_go/core/config/payment/moyasar_config.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';

enum MoyasarPaymentStatus { paid, failed, cancelled }

/// Outcome returned (via Navigator.pop) by [MoyasarPaymentView] to its caller.
class MoyasarPaymentResult {
  final MoyasarPaymentStatus status;
  final String? paymentId; // non-null only when status == paid
  const MoyasarPaymentResult._(this.status, this.paymentId);
  const MoyasarPaymentResult.paid(String id) : this._(MoyasarPaymentStatus.paid, id);
  const MoyasarPaymentResult.failed() : this._(MoyasarPaymentStatus.failed, null);
  const MoyasarPaymentResult.cancelled() : this._(MoyasarPaymentStatus.cancelled, null);
}

/// Arguments for the on-device Moyasar purchase step (pay-before-create).
class MoyasarPaymentArgs {
  final PaymentInitModel init;

  /// The chosen surface — card on both platforms, Apple Pay on iOS only.
  final PaymentMethod paymentMethod;

  /// Human-readable description tagged on the Moyasar payment.
  final String description;

  MoyasarPaymentArgs({
    required this.init,
    required this.paymentMethod,
    required this.description,
  });
}

/// "Still Water" payment screen. A bespoke light surface designed AROUND the
/// Moyasar SDK card (which hardcodes black labels / white inputs and cannot be
/// themed). An aqua light-wash fades to white; the SDK card rests as an elevated
/// white sheet. On a verified `paid` result it pops with the Moyasar payment id
/// (String); on cancel/dismiss it pops with null. 3DS is managed in-app by the
/// SDK; card data goes device->Moyasar (SAQ A preserved).
class MoyasarPaymentView extends StatefulWidget {
  final MoyasarPaymentArgs args;

  const MoyasarPaymentView({super.key, required this.args});

  @override
  State<MoyasarPaymentView> createState() => _MoyasarPaymentViewState();
}

class _MoyasarPaymentViewState extends State<MoyasarPaymentView>
    with SingleTickerProviderStateMixin {
  // Design tokens — this screen is a deliberate light island in a dark app.
  static const Color _teal = Color(0xFF0095AA);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _slate = Color(0xFF64748B);
  static const Color _hairline = Color(0xFFEAF0F2);
  static const Color _aqua = Color(0xFFE6FBFD);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  moyasar.PaymentConfig _buildConfig() {
    return moyasar.PaymentConfig(
      publishableApiKey: MoyasarConfig.publishableApiKey,
      amount: widget.args.init.amountMinor,
      currency: widget.args.init.currency,
      description: widget.args.description,
      metadata: widget.args.init.metadata,
      givenID: widget.args.init.givenId,
      applePay: moyasar.ApplePayConfig(
        merchantId: 'merchant.sa.aquago.moysar',
        label: MoyasarConfig.applePayLabel,
        manual: false,
        saveCard: false,
      ),
    );
  }

  void _onPaymentResult(dynamic result) {
    debugPrint('Moyasar payment result (${result.runtimeType}): $result');
    if (!mounted) return;
    if (result is moyasar.PaymentResponse) {
      print(result.status);
      print(result.description);
      print(result.metadata);
      switch (result.status) {
        case moyasar.PaymentStatus.paid:
          Navigator.of(context).pop(MoyasarPaymentResult.paid(result.id));
          return;
        case moyasar.PaymentStatus.failed:
          // Processor decline (e.g. "DECLINED", "INSUFFICIENT FUNDS"). Surface
          // the reason so it isn't a silent "Payment Not Completed".
          _failWith('${result.status.name}\n$result');
          return;
        case moyasar.PaymentStatus.initiated:
        case moyasar.PaymentStatus.authorized:
        case moyasar.PaymentStatus.captured:
          return; // interim — SDK still handling 3DS; do not pop
      }
    }
    // A genuine user dismissal carries no error worth showing.
    if (result is moyasar.PaymentCanceledError) {
      Navigator.of(context).pop(const MoyasarPaymentResult.cancelled());
      return;
    }
    // Everything else — UnprocessableTokenError (Apple Pay token Moyasar could
    // NOT decrypt → certificate/private-key mismatch), ApiError, or any unknown
    // error. Previously UnprocessableTokenError was swallowed as "cancelled",
    // hiding the exact failure. Surface the error class + detail so it is
    // diagnosable from a TestFlight build (no console access), then return a
    // failed result to the caller.
    _failWith('${result.runtimeType}\n$result');
  }

  /// Shows the raw failure detail in a dialog (so a TestFlight tester can read /
  /// screenshot it), then pops with a failed result. Awaited so the dialog is
  /// not torn down by the route pop.
  Future<void> _failWith(String detail) async {
    if (!mounted) return;
    final isAr = context.isAr;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تعذّر إتمام الدفع' : 'Payment not completed'),
        content: SingleChildScrollView(
          child: Text(
            detail,
            style: const TextStyle(fontSize: 13, color: _ink),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isAr ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(const MoyasarPaymentResult.failed());
  }

  // Staggered fade + slide-up reveal driven by the single intro controller.
  Widget _reveal(double start, double end, Widget child) {
    final a = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * 22),
          child: c,
        ),
      ),
      child: child,
    );
  }

  PreferredSizeWidget _appBar(bool isAr) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      foregroundColor: _ink,
      centerTitle: false,
      title: Text(
        isAr ? 'الدفع' : 'Payment',
        style: const TextStyle(
          color: _ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: _ink),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final topInset = MediaQuery.of(context).padding.top;

    if (!MoyasarConfig.isConfigured) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(isAr),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isAr
                  ? 'إعدادات الدفع غير مكتملة.'
                  : 'Payment is not configured.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _ink),
            ),
          ),
        ),
      );
    }

    final config = _buildConfig();
    final bool showApplePay = widget.args.paymentMethod == PaymentMethod.applePay &&
        !kIsWeb &&
        Platform.isIOS;
    final formatted = (widget.args.init.amountMinor / 100).toStringAsFixed(2);
    final amount = isAr ? '$formatted ر.س' : 'SAR $formatted';
    final desc = widget.args.description;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _appBar(isAr),
      body: Stack(
        children: [
          // Atmosphere: aqua light-wash bleeding down from the top, fading to white.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.46,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_aqua, Color(0x00E6FBFD)],
                ),
              ),
            ),
          ),
          // Soft radial glow behind the hero amount.
          Positioned(
            top: topInset + 36,
            left: -40,
            right: -40,
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _teal.withValues(alpha: 0.10),
                      _teal.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content.
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, topInset + kToolbarHeight + 12, 0, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero amount (floats on the atmosphere — no box).
                  _reveal(
                    0.0,
                    0.55,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'المبلغ المستحق' : 'Amount due',
                            style: const TextStyle(
                              color: _slate,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            amount,
                            style: const TextStyle(
                              color: _teal,
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              desc,
                              style: const TextStyle(color: _slate, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  // The Moyasar card as an elevated white sheet.
                  _reveal(
                    0.18,
                    0.85,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _hairline),
                          boxShadow: [
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.10),
                              blurRadius: 34,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        // Light-theme island: the SDK's TextFormField has no
                        // explicit text color, so under the app's dark theme it
                        // would render white-on-white. A light Theme makes typed
                        // input resolve to dark text.
                        child: Theme(
                          data: ThemeData.light(useMaterial3: true),
                          child: showApplePay
                              ? moyasar.ApplePay(
                                  config: config,
                                  onPaymentResult: _onPaymentResult,
                                )
                              : moyasar.CreditCard(
                                  config: config,
                                  onPaymentResult: _onPaymentResult,
                                  locale: isAr
                                      ? const moyasar.Localization.ar()
                                      : const moyasar.Localization.en(),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Trust line.
                  _reveal(
                    0.5,
                    1.0,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 14, color: _teal),
                        const SizedBox(width: 6),
                        Text(
                          isAr ? 'مدفوعات آمنة ومشفّرة' : 'Secure, encrypted payment',
                          style: const TextStyle(
                            color: _slate,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
