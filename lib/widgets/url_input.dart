import 'package:flutter/material.dart';
import '../core/theme.dart';

class UrlInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final bool isChecking;
  final String? urlType;
  final ValueChanged<String> onChanged;
  final VoidCallback? onPaste;

  const UrlInput({
    super.key,
    required this.controller,
    required this.isValid,
    required this.isChecking,
    this.urlType,
    required this.onChanged,
    this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppTheme.spotifyWhite,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Paste Spotify URL here',
        prefixIcon: Icon(
          Icons.link_rounded,
          color: controller.text.isEmpty
              ? AppTheme.spotifySubtle
              : isValid
                  ? AppTheme.spotifyGreen
                  : AppTheme.logError,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isChecking)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.spotifyGreen,
                  ),
                ),
              )
            else if (controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? AppTheme.spotifyGreen : AppTheme.logError,
                  size: 22,
                ),
              ),
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppTheme.spotifySubtle,
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
          ],
        ),
        helperText: controller.text.isNotEmpty && isValid && urlType != null
            ? 'Detected: ${urlType!.toUpperCase()}'
            : null,
        helperStyle: const TextStyle(
          color: AppTheme.spotifyGreen,
          fontSize: 12,
        ),
        errorText: controller.text.isNotEmpty && !isValid && !isChecking
            ? 'Invalid Spotify URL'
            : null,
      ),
    );
  }
}
