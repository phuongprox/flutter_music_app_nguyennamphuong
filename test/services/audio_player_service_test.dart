import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_music_player_caonientruongson/models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _playerInstance = AudioPlayer();

  // Trạng thái Playlist Nội bộ
  List<String> _playlist = [];
  int _currentIndex = 0;

  String? get currentSongPath =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];

  Stream<Duration> get positionStream => _playerInstance.positionStream;
  Stream<Duration?> get durationStream => _playerInstance.durationStream;
  Stream<PlayerState> get playerStateStream =>
      _playerInstance.playerStateStream;
  Stream<bool> get playingStream => _playerInstance.playingStream;

  Duration get currentPosition => _playerInstance.position;
  Duration get currentDuration => _playerInstance.duration ?? Duration.zero;
  bool get isPlaying => _playerInstance.playing;

  Stream<PlaybackUiState> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackUiState>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) => PlaybackUiState(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> setPlaylist(List<String> songs) async {
    _playlist = List.from(songs);
    _currentIndex = 0;
    if (_playlist.isNotEmpty) {
      await loadAudio(_playlist[_currentIndex]);
    }
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await loadAudio(_playlist[_currentIndex]);
    await play();
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await loadAudio(_playlist[_currentIndex]);
    await play();
  }

  Future<void> loadAudio(String filePath) async {
    try {
      await _playerInstance.setFilePath(filePath);
    } catch (e) {
      throw Exception('Failed to load audio file: $e');
    }
  }

  Future<void> play() => _playerInstance.play();
  Future<void> pause() => _playerInstance.pause();
  Future<void> stop() => _playerInstance.stop();
  Future<void> seek(Duration position) => _playerInstance.seek(position);

  Future<void> setVolume(double volume) => _playerInstance.setVolume(volume);
  Future<void> setSpeed(double speed) => _playerInstance.setSpeed(speed);
  Future<void> setLoopMode(LoopMode loopMode) =>
      _playerInstance.setLoopMode(loopMode);

  void dispose() {
    _playerInstance.dispose();
  }
}
