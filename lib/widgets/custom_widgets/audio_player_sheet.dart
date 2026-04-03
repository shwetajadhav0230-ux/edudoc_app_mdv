// lib/widgets/custom_widgets/audio_player_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerSheet extends StatefulWidget {
  final String title;
  final String author;
  final String coverImageUrl;
  final String? audioUrl; // remote URL (online)
  final String? localAudioPath; // local file path (offline)

  const AudioPlayerSheet({
    super.key,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    this.audioUrl,
    this.localAudioPath,
  });

  @override
  State<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends State<AudioPlayerSheet> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // Prefer local file if it exists
      if (widget.localAudioPath != null &&
          File(widget.localAudioPath!).existsSync()) {
        await _player.setFilePath(widget.localAudioPath!);
      } else if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
        await _player.setUrl(widget.audioUrl!);
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      _player.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d ?? Duration.zero);
      });
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) setState(() {});
      });

      setState(() => _isLoading = false);
      await _player.play();
    } catch (e) {
      if (mounted)
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = _player.playing;
    final progress = (_duration.inMilliseconds > 0)
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cover + Info row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.coverImageUrl,
                  width: 70,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.author,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    if (widget.localAudioPath != null &&
                        File(widget.localAudioPath!).existsSync())
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.offline_bolt,
                                size: 12, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text('Offline',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_hasError)
            const Text('Could not load audio.',
                style: TextStyle(color: Colors.red))
          else if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            )
          else ...[
            // Progress Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
                thumbColor: theme.colorScheme.primary,
                overlayColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (val) {
                  final seek = Duration(
                      milliseconds: (val * _duration.inMilliseconds).toInt());
                  _player.seek(seek);
                },
              ),
            ),

            // Time Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_format(_position),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(_format(_duration),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Controls row: rewind, play/pause, forward
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.replay_10),
                  onPressed: () =>
                      _player.seek(_position - const Duration(seconds: 10)),
                  tooltip: 'Rewind 10s',
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => isPlaying ? _player.pause() : _player.play(),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.forward_10),
                  onPressed: () =>
                      _player.seek(_position + const Duration(seconds: 10)),
                  tooltip: 'Forward 10s',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
