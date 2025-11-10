// lib/services/payment_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io' show Platform;

import '../state/app_state.dart';
import '../utils/constants.dart';

class PaymentService {
  Razorpay? _razorpay;

  void _init() {
    _razorpay ??= Razorpay();
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  void payForTokens(
      BuildContext context, {
        required int tokens,
        String? contact,
        String? email,
      }) {
    // Guard: Only Android/iOS are supported by razorpay_flutter.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Payments are supported only on Android/iOS. Please use a mobile device.'),
        ),
      );
      return;
    }

    _init();

    final amountInPaise = AppConstants.paisePerToken * tokens;

    final options = {
      'key': AppConstants.razorpayKey,
      'amount': amountInPaise, // in paise
      'currency': 'INR',
      'name': AppConstants.merchantName,
      'description': '$tokens tokens',
      'theme': {'color': AppConstants.themeColorHex},
      'prefill': {
        if (contact != null) 'contact': contact,
        if (email != null) 'email': email,
      },
    };

    // Capture dependencies BEFORE opening checkout to avoid using a possibly deactivated context.
    final appState = Provider.of<AppState>(context, listen: false);
    final messenger = ScaffoldMessenger.maybeOf(context);

    void onSuccess(PaymentSuccessResponse response) {
      appState.buyTokens(tokens);
      messenger?.showSnackBar(
        SnackBar(content: Text('Payment successful: ${response.paymentId ?? ''}')),
      );
      dispose();
    }

    void onError(PaymentFailureResponse response) {
      final message = response.message?.toString() ?? 'Payment failed';
      messenger?.showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.code} - $message')),
      );
      dispose();
    }

    void onExternalWallet(ExternalWalletResponse response) {
      messenger?.showSnackBar(
        SnackBar(content: Text('External wallet selected: ${response.walletName ?? ''}')),
      );
    }

    _razorpay!
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

    _razorpay!.open(options);
  }
}
