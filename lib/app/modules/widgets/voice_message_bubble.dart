import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';

class VoiceMessageBubble extends StatefulWidget {
  const VoiceMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isOutgoing,
    required this.responsive,
  });

  final String audioUrl;
  final bool isOutgoing;
  final AppResponsive responsive;

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _player = AudioPlayer();
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _speed = 1.0;
  late final List<double> _bars;

  @override
  void initState() {
    super.initState();
    _bars = _makeBars(widget.audioUrl);
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      final done = s.processingState == ProcessingState.completed;
      setState(() => _isPlaying = s.playing && !done);
      if (done) {
        _player.seek(Duration.zero);
        setState(() => _position = Duration.zero);
      }
    });
  }

  // Génère des hauteurs de barres pseudo-aléatoires mais déterministes
  static List<double> _makeBars(String seed) {
    final rng = math.Random(seed.hashCode.abs());
    return List.generate(32, (i) {
      final center = 0.5 - (i - 15.5).abs() / 62.0;
      return (center + rng.nextDouble() * 0.55).clamp(0.10, 1.0);
    });
  }

  bool get _isLocalFile =>
      !widget.audioUrl.startsWith('http://') &&
      !widget.audioUrl.startsWith('https://');

  Future<void> _togglePlay() async {
    if (_isLoading) return;
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    if (_player.audioSource == null) {
      setState(() => _isLoading = true);
      try {
        if (_isLocalFile) {
          final raw = widget.audioUrl;
          final path = raw.startsWith('file://')
              ? Uri.parse(raw).toFilePath()
              : raw;
          await _player.setFilePath(path);
        } else {
          await _player.setUrl(widget.audioUrl);
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      if (mounted) setState(() => _isLoading = false);
    }
    await _player.play();
  }

  Future<void> _cycleSpeed() async {
    final next = _speed == 1.0
        ? 1.5
        : _speed == 1.5
            ? 2.0
            : 1.0;
    await _player.setSpeed(next);
    if (mounted) setState(() => _speed = next);
  }

  void _seekAt(double ratio) {
    if (_duration == Duration.zero) return;
    _player.seek(
      Duration(milliseconds: (ratio * _duration.inMilliseconds).round()),
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final isOut = widget.isOutgoing;

    final totalMs = _duration.inMilliseconds;
    final posMs = _position.inMilliseconds;
    final progress =
        totalMs > 0 ? (posMs / totalMs).clamp(0.0, 1.0) : 0.0;

    final activeColor = isOut ? Colors.white : AppColors.primary;
    final inactiveColor = isOut
        ? Colors.white.withValues(alpha: 0.28)
        : AppColors.primary.withValues(alpha: 0.22);
    final btnBg = isOut
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.primaryLight;
    final timeColor = isOut
        ? Colors.white.withValues(alpha: 0.72)
        : AppColors.textSecondary;
    final speedBg = isOut
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.10);
    final speedColor = isOut ? Colors.white : AppColors.primary;

    final timeStr = _isPlaying || posMs > 0
        ? _fmt(_position)
        : (_duration == Duration.zero ? '0:00' : _fmt(_duration));
    final speedLabel =
        _speed == 1.0 ? '1×' : _speed == 1.5 ? '1.5×' : '2×';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Play / Pause ─────────────────────────────────────────────
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: r.w(40),
            height: r.w(40),
            decoration:
                BoxDecoration(color: btnBg, shape: BoxShape.circle),
            child: _isLoading
                ? Padding(
                    padding: EdgeInsets.all(r.w(10)),
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: activeColor),
                  )
                : Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: activeColor,
                    size: r.w(24),
                  ),
          ),
        ),
        SizedBox(width: r.w(8)),

        // ── Waveform + durée / vitesse ────────────────────────────────
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barres de forme d'onde (seekable)
              LayoutBuilder(builder: (ctx, constraints) {
                final w = constraints.maxWidth;
                return GestureDetector(
                  onTapDown: (d) =>
                      _seekAt(d.localPosition.dx / w),
                  onHorizontalDragUpdate: (d) =>
                      _seekAt((d.localPosition.dx / w).clamp(0.0, 1.0)),
                  child: SizedBox(
                    height: r.h(32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 0; i < _bars.length; i++) ...[
                          if (i > 0) SizedBox(width: r.w(1.5)),
                          Expanded(
                            child: FractionallySizedBox(
                              heightFactor: _bars[i],
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: i / _bars.length <= progress
                                      ? activeColor
                                      : inactiveColor,
                                  borderRadius:
                                      BorderRadius.circular(r.radius(2)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: r.h(3)),

              // Durée + bouton vitesse
              Row(
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: r.text(11),
                      color: timeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cycleSpeed,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.w(5),
                        vertical: r.h(2),
                      ),
                      decoration: BoxDecoration(
                        color: speedBg,
                        borderRadius: BorderRadius.circular(r.radius(4)),
                      ),
                      child: Text(
                        speedLabel,
                        style: TextStyle(
                          fontSize: r.text(10),
                          color: speedColor,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
