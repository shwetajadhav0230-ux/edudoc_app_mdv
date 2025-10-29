// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class LockUnlockScreen extends StatelessWidget {
  const LockUnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Corrected signature: Should only be (BuildContext context)
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // FIX: Get the contrast color (white/light) for better readability on dark background
    final Color contrastColor = theme.colorScheme.onSurface;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                color: theme.colorScheme.tertiary,
                size: 48,
              ), // FIX: Used 'Icons.school'
              const SizedBox(height: 16),
              // FIX: Explicitly set text color to contrastColor
              Text(
                'EduDoc',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: contrastColor,
                ),
              ),
              Text(
                'Unlock to continue',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 48),

              // Animated Switch between Biometric/Pin views
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: appState.showPasswordUnlock
                    ? _buildPasswordUnlock(context, appState)
                    : _buildBiometricUnlock(
                        context,
                        appState,
                      ), // FIX: Removed incorrect argument
              ),

              TextButton(
                onPressed: () => appState.navigate(AppScreen.home),
                child: Text(
                  'Skip for Now (Prototype Mode)',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIX: Corrected signature: Removed dynamic icons parameter
  Widget _buildBiometricUnlock(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final Color contrastColor =
        theme.colorScheme.onSurface; // Get contrast color

    return Card(
      key: const ValueKey('biometric'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.fingerprint, // FIX: Used 'Icons.fingerprint'
              color: theme.colorScheme.tertiary,
              size: 96,
            ),
            const SizedBox(height: 16),
            // FIX: Explicitly set text color to contrastColor
            Text(
              'Touch Sensor to Unlock',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => appState.navigate(AppScreen.home),
                child: const Text(
                  'Simulate Biometric Unlock',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
              // FIX: Explicitly set text color to ensure visibility
              onPressed: () => appState.togglePinView(true),
              child: Text(
                'Use PIN Instead',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordUnlock(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final Color contrastColor =
        theme.colorScheme.onSurface; // Get contrast color

    return Card(
      key: const ValueKey('password'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // FIX: Explicitly set text color to contrastColor
            Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
            ),
            const SizedBox(height: 16),
            // PIN Dots Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appState.pinCode.length > index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(color: Colors.grey),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Number Pad
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final label = (index + 1).toString();
                if (index == 9) {
                  // Biometric button
                  return IconButton(
                    icon: const Icon(Icons.fingerprint, color: Colors.grey),
                    onPressed: () => appState.togglePinView(false),
                  );
                } else if (index == 10) {
                  // 0 button
                  return ElevatedButton(
                    onPressed: () => appState.pinEnter('0'),
                    child: const Text('0', style: TextStyle(fontSize: 20)),
                  );
                } else if (index == 11) {
                  // Backspace
                  return IconButton(
                    icon: const Icon(Icons.backspace, color: Colors.grey),
                    onPressed: appState.pinClear,
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () => appState.pinEnter(label),
                    child: Text(label, style: const TextStyle(fontSize: 20)),
                  );
                }
              },
            ),
            if (appState.pinCode.length == 4 &&
                appState.pinCode != appState.correctPin)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Incorrect PIN. Try again. (Hint: 1234)',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
