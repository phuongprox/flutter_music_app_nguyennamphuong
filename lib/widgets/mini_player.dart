import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../models/song_model.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static SongModel _getStaticPlaceholder() {
    return SongModel(
      id: 'demo_mini_001',
      title: 'Your music library',
      artist: 'Tap to browse songs',
      filePath: '',
      duration: Duration.zero,
    );
  }

  // --- Xây dựng Giao diện (Build UI) ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NowPlayingScreen()),
        );
      },
      child: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong ?? _getStaticPlaceholder();
          final isStatic = provider.currentSong == null;

          _handleAnimationState(isStatic);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isStatic ? 70 : 80,
            decoration: _buildDecoration(isStatic),
            child: Column(
              children: [
                if (!isStatic) _buildProgressBar(provider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildAlbumArt(song, isStatic),
                        const SizedBox(width: 12),
                        _buildSongInfo(song, isStatic),
                        if (!isStatic) _buildRealControls(provider),
                        if (isStatic) _buildStaticControls(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAnimationState(bool isStatic) {
    if (!isStatic && _animationController.isAnimating) {
      _animationController.stop();
    } else if (isStatic && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    }
  }

  BoxDecoration _buildDecoration(bool isStatic) {
    return BoxDecoration(
      color: isStatic ? Colors.blueGrey[50] : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isStatic ? 0.05 : 0.1),
          blurRadius: isStatic ? 4 : 8,
          offset: const Offset(0, -3),
        ),
      ],
      border:
          isStatic ? Border.all(color: Colors.blueGrey[100]!, width: 1) : null,
    );
  }

  Widget _buildProgressBar(AudioProvider provider) {
    return StreamBuilder<double>(
      stream: provider.playbackStateStream.map((state) {
        final duration = state?.duration.inMilliseconds ?? 0;
        final position = state?.position.inMilliseconds ?? 0;
        return duration > 0 ? position / duration : 0.0;
      }),
      initialData: 0.0,
      builder: (context, snapshot) {
        return LinearProgressIndicator(
          value: snapshot.data,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xFF1DB954),
          ),
          minHeight: 2,
        );
      },
    );
  }

  Widget _buildAlbumArt(SongModel song, bool isStatic) {
    return ScaleTransition(
      scale: isStatic ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isStatic ? Colors.blue[100] : Colors.grey[200],
          border: isStatic
              ? Border.all(
                  color: Colors.blue[300]!,
                  width: 1.5,
                )
              : null,
        ),
        child: song.albumArt != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(song.albumArt!),
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                isStatic ? Icons.music_note : Icons.album,
                color: isStatic ? Colors.blue : Colors.grey,
              ),
      ),
    );
  }

  Widget _buildSongInfo(SongModel song, bool isStatic) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.title,
            style: TextStyle(
              color: isStatic ? Colors.blue[800] : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: isStatic ? 15 : 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            song.artist,
            style: TextStyle(
              color: isStatic ? Colors.blue[600] : Colors.grey,
              fontSize: isStatic ? 12 : 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRealControls(AudioProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<bool>(
          stream: provider.playingStream,
          initialData: provider.isPlaying,
          builder: (context, snapshot) {
            return IconButton(
              icon: Icon(
                snapshot.data ?? false ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
                size: 30,
              ),
              onPressed: provider.playPause,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.black),
          onPressed: provider.next,
        ),
      ],
    );
  }

  Widget _buildStaticControls() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.play_arrow, color: Colors.blue, size: 30),
        SizedBox(width: 8),
        Text(
          'PLAY',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
