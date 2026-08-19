import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';

/// Bulle de lecture de message vocal (style WhatsApp).
///
/// - [isOutgoing] : bulle bleue (envoyée) ou grise (reçue)
/// - Lecture progressive via just_audio
/// - Slider seekable + durée affichée
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

  @override
  void initState() {
    super.initState();
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      final completed = s.processingState == ProcessingState.completed;
      setState(() => _isPlaying = s.playing && !completed);
      if (completed) {
        _player.seek(Duration.zero);
        setState(() => _position = Duration.zero);
      }
    });
  }

  Future<void> _togglePlay() async {
    if (_isLoading) return;
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    if (_player.audioSource == null) {
      setState(() => _isLoading = true);
      try {
        await _player.setUrl(widget.audioUrl);
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      if (mounted) setState(() => _isLoading = false);
    }
    await _player.play();
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
    final progress = totalMs > 0 ? posMs / totalMs : 0.0;

    final activeColor = isOut ? Colors.white : AppColors.primary;
    final inactiveColor =
        isOut ? Colors.white.withValues(alpha: 0.32) : AppColors.border;
    final textColor =
        isOut ? Colors.white.withValues(alpha: 0.75) : AppColors.textSecondary;
    final btnBg = isOut
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.primary.withValues(alpha: 0.10);

    final displayStr = _isPlaying || posMs > 0
        ? _fmt(_position)
        : (_duration == Duration.zero ? '0:00' : _fmt(_duration));

    return SizedBox(
      width: r.w(210),
      child: Row(
        children: [
          // ── Bouton play / pause ───────────────────────────────────────
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: r.w(38),
              height: r.w(38),
              decoration: BoxDecoration(color: btnBg, shape: BoxShape.circle),
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.all(r.w(10)),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: activeColor),
                    )
                  : Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: activeColor,
                      size: r.w(22),
                    ),
            ),
          ),
          SizedBox(width: r.w(8)),

          // ── Barre de progression + durée ─────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: r.h(3),
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: r.w(5)),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: activeColor,
                    inactiveTrackColor: inactiveColor,
                    thumbColor: activeColor,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: totalMs > 0
                        ? (v) => _player.seek(
                              Duration(milliseconds: (v * totalMs).round()),
                            )
                        : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: r.w(4), bottom: r.h(2)),
                  child: Text(
                    displayStr,
                    style: TextStyle(fontSize: r.text(11), color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
