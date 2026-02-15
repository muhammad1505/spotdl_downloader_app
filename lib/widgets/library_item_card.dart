import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/download_item.dart';

class LibraryItemCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onOpenFolder;

  const LibraryItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onShare,
    this.onOpenFolder,
  });

  IconData _getStatusIcon() {
    switch (item.status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'error':
        return Icons.error_rounded;
      case 'downloading':
        return Icons.downloading_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  Color _getStatusColor() {
    switch (item.status) {
      case 'completed':
        return AppTheme.spotifyGreen;
      case 'error':
        return AppTheme.logError;
      case 'downloading':
        return AppTheme.logWarning;
      default:
        return AppTheme.spotifySubtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('download_${item.id}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: AppTheme.logError.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.logError),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.spotifyGreen.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.share_rounded, color: AppTheme.spotifyGreen),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onDelete?.call();
          return true;
        } else {
          onShare?.call();
          return false;
        }
      },
      child: Card(
        child: InkWell(
          onTap: onOpenFolder,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Album art placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.spotifyGrey,
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.spotifyGreen.withAlpha(40),
                        AppTheme.spotifyGrey,
                      ],
                    ),
                  ),
                  child: item.albumArt != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.albumArt!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.music_note_rounded,
                              color: AppTheme.spotifyGreen,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.music_note_rounded,
                          color: AppTheme.spotifyGreen,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),
                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.artist,
                        style: TextStyle(
                          color: AppTheme.spotifySubtle,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.duration != null) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: AppTheme.spotifySubtle.withAlpha(150),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.duration!,
                              style: TextStyle(
                                color: AppTheme.spotifySubtle.withAlpha(150),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (item.fileSize != null) ...[
                            Icon(
                              Icons.storage_rounded,
                              size: 12,
                              color: AppTheme.spotifySubtle.withAlpha(150),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.fileSize!,
                              style: TextStyle(
                                color: AppTheme.spotifySubtle.withAlpha(150),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status icon
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
