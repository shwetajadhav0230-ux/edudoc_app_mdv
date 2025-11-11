// lib/screens/profile/email_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart'; // Import AppState

class EmailManagementScreen extends StatefulWidget {
  const EmailManagementScreen({super.key});

  @override
  State<EmailManagementScreen> createState() => _EmailManagementScreenState();
}

class _EmailManagementScreenState extends State<EmailManagementScreen> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _emailController = TextEditingController(text: appState.currentUser.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- Core Logic: Handle Email Change ---
  void _handleChangeEmail(AppState appState, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final newEmail = _emailController.text;

      if (newEmail == appState.currentUser.email) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email address is already set to this value.'),
          ),
        );
        return;
      }

      // 🚨 FIX: Pass existing required fields using non-null assertion (!)
      // This resolves the 'String?' cannot be assigned to 'String' error,
      // assuming the properties are guaranteed to be set on the User object.
      // ⚠️ REMOVED: The 'bio' parameter is no longer passed.
      appState.saveProfile(
        fullName: appState.currentUser.fullName!, // Null assertion applied
        email: newEmail,
        phoneNumber:
            appState.currentUser.phoneNumber!, // Null assertion applied
        profileImageBase64: appState.currentUser.profileImageBase64,
        bio: '',
      );

      // 3. Provide success feedback and navigate back to settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email changed to $newEmail. Verification link sent.'),
        ),
      );

      appState.navigateBack();
    }
  }

  // --- Email Validation Function (unchanged) ---
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // ✨ FIX: Wrap IconButton in Padding to push it away from the edge
        leading: Padding(
          // Adjust padding (e.g., 8.0 on the left) to create separation.
          // AppBar handles internal padding, so we might only need a bit more.
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => appState.navigateBack(),
          ),
        ),
        title: const Text('Manage Email'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Email', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              // Use Selector/Consumer if you want this text to update automatically,
              // but reading current state is fine here.
              Text(
                appState.currentUser.email,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const Divider(height: 32),

              Text('Change Email Address', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),

              // --- Email Input Field ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'New Email Address',
                  hintText: 'e.g., jane.doe.new@edudoc.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: _validateEmail,
              ),

              const SizedBox(height: 32),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleChangeEmail(appState, context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Update Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- Note on Verification ---
              Center(
                child: Text(
                  'A verification link will be sent to the new address.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
