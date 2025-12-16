import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _playerInstance = AudioPlayer();
  Stream<Duration> get positionStream => _playerInstance.positionStream;
  Stream<Duration?> get durationStream => _playerInstance.durationStream;
  Stream<PlayerState> get playerStateStream =>
      _playerInstance.playerStateStream;
  Stream<bool> get playingStream => _playerInstance.playingStream;

  Duration get currentPosition => _playerInstance.position;
  Duration? get currentDuration => _playerInstance.duration;
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
