import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/download_options.dart';

class DownloadOptionsCard extends StatelessWidget {
  final DownloadOptions options;
  final ValueChanged<DownloadOptions> onChanged;

  const DownloadOptionsCard({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: const Icon(
            Icons.tune_rounded,
            color: AppTheme.spotifyGreen,
          ),
          title: const Text(
            'Download Options',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            '${options.quality} kbps • MP3',
            style: TextStyle(
              color: AppTheme.spotifySubtle,
              fontSize: 12,
            ),
          ),
          children: [
            // Audio Quality
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Audio Quality',
                style: TextStyle(
                  color: AppTheme.spotifySubtle,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['128', '192', '320'].map((q) {
                final isSelected = options.quality == q;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$q kbps'),
                      selected: isSelected,
                      onSelected: (_) {
                        onChanged(options.copyWith(quality: q));
                      },
                      selectedColor: AppTheme.spotifyGreen,
                      backgroundColor: AppTheme.spotifyGrey,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.spotifySubtle,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Toggle Options
            _buildToggle(
              'Auto skip if file exists',
              Icons.skip_next_rounded,
              options.skipExisting,
              (val) => onChanged(options.copyWith(skipExisting: val)),
            ),
            _buildToggle(
              'Embed album art',
              Icons.image_rounded,
              options.embedArt,
              (val) => onChanged(options.copyWith(embedArt: val)),
            ),
            _buildToggle(
              'Normalize audio',
              Icons.equalizer_rounded,
              options.normalizeAudio,
              (val) => onChanged(options.copyWith(normalizeAudio: val)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.spotifySubtle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
