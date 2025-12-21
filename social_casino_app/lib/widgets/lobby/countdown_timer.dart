import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final String? label;
  final bool compact;

  const CountdownTimer({
    super.key,
    required this.endTime,
    this.label,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = widget.endTime.difference(now);
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return _buildExpiredBadge();
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    if (widget.compact) {
      return _buildCompactTimer(days, hours, minutes, seconds);
    }

    return _buildFullTimer(days, hours, minutes, seconds);
  }

  Widget _buildExpiredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.casinoAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.casinoAccent),
      ),
      child: const Text(
        'Expired',
        style: TextStyle(
          color: AppColors.casinoAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactTimer(int days, int hours, int minutes, int seconds) {
    String timeString;
    if (days > 0) {
      timeString = '${days}d ${hours}h';
    } else if (hours > 0) {
      timeString = '${hours}h ${minutes}m';
    } else {
      timeString = '${minutes}m ${seconds}s';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.gradientGold,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTimer(int days, int hours, int minutes, int seconds) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (days > 0) ...[
              _buildTimeUnit(days.toString().padLeft(2, '0'), 'D'),
              _buildSeparator(),
            ],
            _buildTimeUnit(hours.toString().padLeft(2, '0'), 'H'),
            _buildSeparator(),
            _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'M'),
            _buildSeparator(),
            _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'S'),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.casinoBgCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.casinoPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: AppColors.casinoPurple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
