import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../models/playback_state_model.dart';

class AudioProvider extends ChangeNotifier {
  // Dịch vụ cốt lõi
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  // Trạng thái phát lại
  List<SongModel> _playlist = [];
  int _currentIndex = 0;

  // Cài đặt
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  double _speed = 1.0;

  AudioProvider(this._audioService, this._storageService) {
    _loadInitialState();
  }

  // =================================================================
  // LỌC THÔNG TIN (Getters)
  // =================================================================

  // Getters trạng thái phát lại tức thì
  PlaybackUiState get currentPlaybackState => PlaybackUiState(
        position: _audioService.currentPosition,
        duration: _audioService.currentDuration ?? Duration.zero,
        isPlaying: _audioService.isPlaying,
      );

  bool get isPlaying => _audioService.isPlaying;
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];

  // Getters cài đặt
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  double get speed => _speed;

  // Stream Getters
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<PlaybackUiState> get playbackStateStream =>
      _audioService.playbackStateStream;

  // =================================================================
  // KHỞI TẠO
  // =================================================================

  Future<void> _loadInitialState() async {
    _isShuffleEnabled = await _storageService.getShuffleState();

    final repeatModeIndex = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatModeIndex];
    await _audioService.setLoopMode(_loopMode);

    final volume = await _storageService.getVolume();
    await _audioService.setVolume(volume);

    _speed = await _storageService.getSpeed();
    await _audioService.setSpeed(_speed);
  }

  // =================================================================
  // ĐIỀU KHIỂN DANH SÁCH PHÁT
  // =================================================================

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    final song = _playlist[index];

    await _audioService.loadAudio(song.filePath);
    await _audioService.play();
    await _storageService.saveLastPlayed(song.id);

    notifyListeners();
  }

  // =================================================================
  // ĐIỀU KHIỂN PHÁT LẠI
  // =================================================================

  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    // Nếu đã phát > 3 giây, tua lại từ đầu
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
      return;
    }

    if (_playlist.isEmpty) return;

    // Chuyển bài trước
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> seek(Duration position) => _audioService.seek(position);

  // =================================================================
  // ĐIỀU CHỈNH CÀI ĐẶT
  // =================================================================

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }

    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    await _storageService.saveVolume(volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _audioService.setSpeed(speed);
    await _storageService.saveSpeed(speed);
    notifyListeners();
  }

  // =================================================================
  // TIỆN ÍCH
  // =================================================================

  int _getRandomIndex() {
    if (_playlist.isEmpty) return 0;
    // Dùng Random an toàn hơn so với DateTime.now()
    final random = Random();
    return random.nextInt(_playlist.length);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
