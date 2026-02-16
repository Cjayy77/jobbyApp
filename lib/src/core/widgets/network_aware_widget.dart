import 'package:flutter/material.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? offlineChild;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.offlineChild,
  });

  @override
  Widget build(BuildContext context) {
    // For now, just return the child. We'll implement connectivity check later
    return child;
  }
}
