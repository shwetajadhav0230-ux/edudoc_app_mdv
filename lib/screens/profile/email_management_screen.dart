// lib/screens/profile/email_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class EmailManagementScreen extends StatefulWidget {
  const EmailManagementScreen({super.key});

  @override
  State<EmailManagementScreen> createState() => _EmailManagementScreenState();
}

class _EmailManagementScreenState extends State<EmailManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with current email
    final appState = Provider.of<AppState>(context, listen: false);
    _emailController.text = appState.currentUser.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Email Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Update Primary Email', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'New Email', border: OutlineInputBorder()),
                validator: appState.validateEmail, // Reuses existing validator
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Confirm with Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val == null || val.isEmpty ? 'Password required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    appState.updateEmail(_passwordController.text, _emailController.text.trim(), context);
                  }
                },
                child: const Text('Send Verification Link'),
              ),
              const Divider(height: 64),
              const Text('Email Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: const Text('Promotional Emails'),
                subtitle: const Text('Get updates on new documents and offers'),
                value: appState.isPromoEmailEnabled, // Uses AppState
                onChanged: (val) => appState.togglePromoEmails(val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}