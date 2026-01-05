/// Loading Indicator Widget.
/// Reusable loading spinner for async operations.
///
/// Layer: Presentation (Widgets)
/// Responsibility: Consistent loading UI across the app.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/lottie_loading.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 120.0, // Increased default size for Lottie
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LottieLoading(size: size, message: message),
    );
  }
}
