import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxMilliseconds = duration.inMilliseconds;
    final max = maxMilliseconds > 0 ? maxMilliseconds.toDouble() : 1.0;

    final currentPositionMilliseconds = position.inMilliseconds;
    final value =
        currentPositionMilliseconds.clamp(0, maxMilliseconds).toDouble();

    return Column(
      children: [
        _buildSeekSlider(value, max),
        _buildTimeLabels(),
      ],
    );
  }

  Widget _buildSeekSlider(double value, double max) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 6,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 16,
        ),
        activeTrackColor: const Color(0xFF1DB954),
        inactiveTrackColor: Colors.grey[800],
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF1DB954).withOpacity(0.3),
      ),
      child: Slider(
        value: value,
        min: 0.0,
        max: max,
        onChanged: (v) {
          onSeek(Duration(milliseconds: v.toInt()));
        },
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDuration(position),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            _formatDuration(duration),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return '$minutes:$seconds';
  }
}
