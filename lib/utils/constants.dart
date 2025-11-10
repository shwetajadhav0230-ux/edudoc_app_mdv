
// lib/utils/constants.dart

class AppConstants {
  // TODO: Replace with your Razorpay Key ID
  static const String razorpayKey = 'rzp_test_BrZoJm8FvGfLhd';

  // Pricing: how many paise (1 INR = 100 paise) per token.
  // TODO: Set this according to your pricing model.
  static const int paisePerToken = 100; // e.g., 1 token = ₹1.00

  static const String merchantName = 'EduDoc';

  // Hex color used in Razorpay checkout (must be a string like '#3399cc')
  static const String themeColorHex = '#6366F1';
}
