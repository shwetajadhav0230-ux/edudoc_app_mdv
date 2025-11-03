import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming AppState is accessible here (e.g., imported from 'package:yourapp/state/app_state.dart')
// For this example to be runnable, I will assume AppState is defined or imported correctly.
// NOTE: You must ensure the AppState is available in the widget tree above this component.
import '../../state/app_state.dart';

class WalletButton extends StatelessWidget {
  final VoidCallback onTap;
  const WalletButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Access the AppState using Provider
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Define the color for the button background (slightly darker than the main background)
    final Color buttonBackgroundColor = theme.cardColor;
    // Define the tertiary color (Chrome Yellow/Amber) for the border/icon
    final Color tertiaryColor = theme.colorScheme.tertiary;

    // MODIFIED: Increased roundness value
    const double borderRadiusValue = 25.0;

    // Using InkWell to make the whole area clickable
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        borderRadiusValue,
      ), // Increased roundness
      // Styling the whole container to look like a chip
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: buttonBackgroundColor,
          borderRadius: BorderRadius.circular(
            borderRadiusValue,
          ), // Increased roundness
          // Outer border: Chrome yellow
          border: Border.all(color: tertiaryColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(Icons.monetization_on, color: tertiaryColor, size: 18),
            // MODIFIED: Distance between icon and text set to 0
            const SizedBox(width: 0),
            // MODIFIED: Removed the inner border and kept only padding/styling for the text
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              // decoration property removed here to eliminate the inner border
              child: Text(
                '${appState.walletTokens}',
                style: TextStyle(
                  color: theme
                      .textTheme
                      .bodyLarge
                      ?.color, // Use primary text color
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
