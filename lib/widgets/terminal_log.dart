import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/log_entry.dart';

class TerminalLog extends StatefulWidget {
  final List<LogEntry> logs;

  const TerminalLog({super.key, required this.logs});

  @override
  State<TerminalLog> createState() => _TerminalLogState();
}

class _TerminalLogState extends State<TerminalLog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(TerminalLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return AppTheme.logInfo;
      case LogLevel.warning:
        return AppTheme.logWarning;
      case LogLevel.error:
        return AppTheme.logError;
      case LogLevel.success:
        return AppTheme.logSuccess;
    }
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERR ]';
      case LogLevel.success:
        return '[ OK ]';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.spotifyLightGrey.withAlpha(80),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terminal header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.spotifyGrey.withAlpha(150),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.logs.isNotEmpty
                          ? AppTheme.spotifyGreen
                          : AppTheme.spotifyLightGrey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terminal Output',
                    style: TextStyle(
                      color: AppTheme.spotifySubtle,
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.logs.length} lines',
                    style: TextStyle(
                      color: AppTheme.spotifySubtle.withAlpha(150),
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            ),
            // Log content
            Expanded(
              child: widget.logs.isEmpty
                  ? Center(
                      child: Text(
                        'Awaiting output...',
                        style: TextStyle(
                          color: AppTheme.spotifySubtle.withAlpha(100),
                          fontSize: 12,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.logs.length,
                      itemBuilder: (context, index) {
                        final log = widget.logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 11,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: '${_getLevelPrefix(log.level)} ',
                                  style: TextStyle(
                                    color: _getLogColor(log.level).withAlpha(180),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: log.message,
                                  style: TextStyle(
                                    color: _getLogColor(log.level),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
