// lib/services/payment_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io' show Platform;

import '../state/app_state.dart';
import '../utils/constants.dart';

class PaymentService {
  // ✅ Singleton Pattern: Ensure only one instance exists
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Razorpay? _razorpay;

  // ✅ Store context-specific data for the *current* active payment
  int? _pendingTokens;
  AppState? _pendingAppState;
  ScaffoldMessengerState? _pendingMessenger;

  /// Initializes Razorpay and sets up listeners only once.
  void _init() {
    if (_razorpay != null) return; // Already initialized

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  /// Triggered when payment is successful
  void _onSuccess(PaymentSuccessResponse response) {
    if (_pendingAppState != null && _pendingTokens != null) {
     _pendingAppState!.buyTokens(_pendingTokens!);
      _pendingMessenger?.showSnackBar(
        const SnackBar(content: Text('Payment Received! Updating wallet...')),
      );
      _clearPendingData();
    }
    _clearPendingData();
  }

  /// Triggered when payment fails
  void _onError(PaymentFailureResponse response) {
    final message = response.message ?? 'Payment failed';
    _pendingMessenger?.showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.code} - $message')),
    );
    _clearPendingData();
  }

  /// Triggered when an external wallet (like Paytm) is selected
  void _onExternalWallet(ExternalWalletResponse response) {
    _pendingMessenger?.showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName ?? ''}')),
    );
  }

  /// Clears the temporary state after a transaction
  void _clearPendingData() {
    _pendingTokens = null;
    _pendingAppState = null;
    _pendingMessenger = null;
  }

  /// Main method to initiate payment
  void payForTokens(
      BuildContext context, {
        required int tokens,
        String? contact,
        String? email,
      }) {
    // Guard: Only Android/iOS are supported by razorpay_flutter.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Payments are supported only on Android/iOS. Please use a mobile device.'),
        ),
      );
      return;
    }

    _init(); // Ensure Razorpay is initialized

    // ✅ Store dependencies before opening checkout
    _pendingTokens = tokens;
    _pendingAppState = Provider.of<AppState>(context, listen: false);
    _pendingMessenger = ScaffoldMessenger.maybeOf(context);

    final amountInPaise = AppConstants.paisePerToken * tokens;
    final userId = _pendingAppState?.currentUser.id;
    if (userId == null || userId.isEmpty) {
      _pendingMessenger?.showSnackBar(const SnackBar(content: Text('Error: User not found')));
      return;
    }

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
      'notes': {
        'user_id': userId,
        }
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      _onError(PaymentFailureResponse(0, e.toString(), null));
    }
  }

  /// Clean up resources (Call only when app terminates)
  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}