import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music_player_caonientruongson/models/playback_state_model.dart';

void main() {
  group('PlaybackUiState Model Tests', () {
    test('Constructor sets position, duration, and isPlaying correctly', () {
      final positionValue = Duration(seconds: 10);
      final durationValue = Duration(seconds: 100);

      final state = PlaybackUiState(
        position: positionValue,
        duration: durationValue,
        isPlaying: true,
      );

      expect(state.position, positionValue);
      expect(state.duration, durationValue);
      expect(state.isPlaying, isTrue);
    });

    test('Progress getter calculates the correct fraction', () {
      final state = PlaybackUiState(
        position: Duration(milliseconds: 250),
        duration: Duration(milliseconds: 1000),
        isPlaying: false,
      );

      expect(state.progress, 0.25);
    });

    test('Progress returns 0.0 when duration is zero', () {
      final state = PlaybackUiState(
        position: Duration(seconds: 50),
        duration: Duration.zero,
        isPlaying: true,
      );

      expect(state.progress, 0.0);
    });

    test('Progress returns 1.0 when position equals duration', () {
      final testDuration = Duration(minutes: 5);
      final state = PlaybackUiState(
        position: testDuration,
        duration: testDuration,
        isPlaying: true,
      );

      expect(state.progress, 1.0);
    });
  });
}
