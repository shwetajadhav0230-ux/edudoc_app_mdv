import 'package:flutter/material.dart';

class WalletButton extends StatelessWidget {
  final VoidCallback onTap;
  const WalletButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.account_balance_wallet),
    );
  }
}
