import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/download_item.dart';
import '../services/storage_service.dart';
import '../widgets/library_item_card.dart';

class LibraryScreen extends StatefulWidget {
  final StorageService? storageService;

  const LibraryScreen({super.key, this.storageService});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final StorageService _storageService;
  final TextEditingController _searchController = TextEditingController();

  List<DownloadItem> _downloads = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, track, playlist
  String _sortBy = 'newest'; // newest, name, size

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _loadDownloads();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDownloads() async {
    setState(() => _isLoading = true);

    try {
      List<DownloadItem> downloads;

      if (_searchController.text.isNotEmpty) {
        downloads = await _storageService.searchDownloads(_searchController.text);
      } else if (_filterType != 'all') {
        downloads = await _storageService.getDownloadsByType(_filterType);
      } else {
        downloads = await _storageService.getDownloadsSorted(_sortBy);
      }

      if (mounted) {
        setState(() {
          _downloads = downloads;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDownload(DownloadItem item) async {
    if (item.id == null) return;

    await _storageService.deleteDownload(item.id!);
    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.spotifyGreen,
            onPressed: () async {
              await _storageService.insertDownload(item);
              _loadDownloads();
            },
          ),
        ),
      );
    }

    _loadDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Text(
                '📂',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              const Text(
                'Library',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.spotifyGreen.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_downloads.length} tracks',
                  style: const TextStyle(
                    color: AppTheme.spotifyGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _loadDownloads(),
            decoration: InputDecoration(
              hintText: 'Search downloads...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.spotifySubtle),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: AppTheme.spotifySubtle,
                      onPressed: () {
                        _searchController.clear();
                        _loadDownloads();
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Filter & Sort Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 6),
                _buildFilterChip('Tracks', 'track'),
                const SizedBox(width: 6),
                _buildFilterChip('Playlists', 'playlist'),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 24,
                  color: AppTheme.spotifyLightGrey,
                ),
                const SizedBox(width: 16),
                _buildSortChip('Newest', 'newest'),
                const SizedBox(width: 6),
                _buildSortChip('A-Z', 'name'),
                const SizedBox(width: 6),
                _buildSortChip('Size', 'size'),
              ],
            ),
          ),
        ),

        // Downloads List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.spotifyGreen,
                  ),
                )
              : _downloads.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppTheme.spotifyGreen,
                      onRefresh: _loadDownloads,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: _downloads.length,
                        itemBuilder: (context, index) {
                          final item = _downloads[index];
                          return LibraryItemCard(
                            item: item,
                            onDelete: () => _deleteDownload(item),
                            onShare: () {
                              // TODO: Implement share
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sharing coming soon!')),
                              );
                            },
                            onOpenFolder: () {
                              // TODO: Implement open folder
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Open folder coming soon!')),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_rounded,
            size: 80,
            color: AppTheme.spotifyGreen.withAlpha(60),
          ),
          const SizedBox(height: 16),
          const Text(
            'No downloads yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.spotifySubtle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your downloaded tracks will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.spotifySubtle.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _filterType = type);
        _loadDownloads();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.spotifyGreen : AppTheme.spotifyGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.spotifySubtle,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String sort) {
    final isSelected = _sortBy == sort;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = sort);
        _loadDownloads();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.spotifyGreen.withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.spotifyGreen : AppTheme.spotifyLightGrey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                size: 14,
                color: AppTheme.spotifyGreen,
              ),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.spotifyGreen : AppTheme.spotifySubtle,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
