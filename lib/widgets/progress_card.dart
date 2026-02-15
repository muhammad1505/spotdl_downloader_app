import 'package:flutter/material.dart';
import '../core/theme.dart';

class ProgressCard extends StatelessWidget {
  final int progress;
  final String statusMessage;
  final String status;
  final VoidCallback? onCancel;

  const ProgressCard({
    super.key,
    required this.progress,
    required this.statusMessage,
    required this.status,
    this.onCancel,
  });

  String _getStatusEmoji() {
    switch (status) {
      case 'downloading':
        return '⬇️';
      case 'converting':
        return '🔄';
      case 'completed':
        return '✅';
      case 'error':
        return '❌';
      case 'cancelled':
        return '🚫';
      default:
        return '⏳';
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'downloading':
        return 'Downloading...';
      case 'converting':
        return 'Converting...';
      case 'completed':
        return 'Completed!';
      case 'error':
        return 'Error';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Processing...';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return AppTheme.spotifyGreen;
      case 'error':
        return AppTheme.logError;
      case 'cancelled':
        return AppTheme.logWarning;
      default:
        return AppTheme.spotifyGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'downloading' || status == 'converting';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              children: [
                Text(
                  _getStatusEmoji(),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Text(
                    '$progress%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _getStatusColor(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isActive ? progress / 100.0 : (status == 'completed' ? 1.0 : 0.0),
                minHeight: 8,
                backgroundColor: AppTheme.spotifyGrey,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            ),
            const SizedBox(height: 12),
            // Status message
            Text(
              statusMessage,
              style: TextStyle(
                color: AppTheme.spotifySubtle,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Cancel button
            if (isActive && onCancel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: const Text('Cancel Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.logError,
                    side: const BorderSide(color: AppTheme.logError),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
