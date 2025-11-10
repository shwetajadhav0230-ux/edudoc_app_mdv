import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/payment_service.dart';
import '../../state/app_state.dart';
import '../../utils/constants.dart';

class BuyTokensModal extends StatelessWidget {
  const BuyTokensModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final packages = [100, 500, 1000, 2500];

    return AlertDialog(
      title: Text(
        'Purchase Tokens',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      // MODIFIED: Use a ConstrainedBox instead of SizedBox with double.maxFinite
      // to better control the width of the dialog content.
      content: SizedBox(
        width: 400,
        height: 280,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 120,
          ),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final amount = packages[index];
            final isDarkTheme = theme.brightness == Brightness.dark;
            final tokenIconColor = theme.colorScheme.tertiary;

            return GestureDetector(
              onTap: () {
                // Start Razorpay checkout for the selected tokens package
                final user = appState.currentUser;
                Navigator.of(context).pop(); // Close the modal before opening checkout
                PaymentService().payForTokens(
                  context,
                  tokens: amount,
                  contact: user.phoneNumber,
                  email: user.email,
                );
              },
              // MODIFIED: Set a higher elevation for a prominent shadow
              child: Card(
                elevation: 12.0, // Increased elevation for a better shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  // Optional: Add a subtle border for contrast in dark mode
                  side: isDarkTheme
                      ? BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  )
                      : BorderSide.none,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        // NEW: Combine token amount and icon
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SWAPPED: Icon now comes first
                          Icon(
                            Icons
                                .monetization_on, // Chrome yellow coins stack icon
                            color: tokenIconColor,
                            size: 24, // REDUCED SIZE from 32
                          ),
                          const SizedBox(width: 4),
                          // SWAPPED: Text now comes second
                          Text(
                            '$amount',
                            style: TextStyle(
                              fontSize: 24, // REDUCED SIZE from 32
                              fontWeight: FontWeight.w900,
                              color: tokenIconColor,
                            ),
                          ),
                        ],
                      ),
                      // Text('Tokens') removed and replaced by the icon in the Row above
                      const SizedBox(height: 4),
                      Text(
                        '₹${((amount * AppConstants.paisePerToken) / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16, // Explicitly set size for balance
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          // MODIFIED: Set the text color to red
          child: Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
