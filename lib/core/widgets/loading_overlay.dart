import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryGreen),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message!,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
