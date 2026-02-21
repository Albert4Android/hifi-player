import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../audio/player_controller.dart';
import '../../ui/app_theme.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with TickerProviderStateMixin {
  late final AnimationController _blink;
  late final AnimationController _rainbow;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _rainbow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _blink.dispose();
    _rainbow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<int?>(
      stream: PlayerController.I.currentIndexStream,
      builder: (context, indexSnap) {
        final song = PlayerController.I.currentSong;
        final queue = PlayerController.I.queue;
        final currentIndex = indexSnap.data ?? 0;

        if (song == null) {
          return const Scaffold(
            body: Center(child: Text('Nothing is playing')),
          );
        }

        final title = song.title;
        final artistRaw = (song.artist ?? '').trim();
        final artist = artistRaw.isEmpty || artistRaw.toLowerCase() == '<unknown>'
            ? 'Unknown artist'
            : artistRaw;

        return Scaffold(
          appBar: AppBar(title: const Text('Now Playing')),
          body: SafeArea(
            top: false,
            bottom: true,
            left: true,
            right: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Container(
                            color: AppTheme.surface2,
                            child: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              artworkFit: BoxFit.cover,
                              artworkBorder: BorderRadius.zero,
                              nullArtworkWidget: _fallbackArtworkSmall(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textDim,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 6),

                              _MarqueeText(
                                title,
                                style: theme.textTheme.titleLarge?.copyWith(height: 1.05),
                                // oscylacja + pauza na końcach
                                pingPong: true,
                                edgePause: const Duration(milliseconds: 450),
                              ),

                              const Spacer(),
                              const _VuMeterRealSlot(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _ProgressBarFullWidth(),
                  const SizedBox(height: 6),
                  const _TransportControlsFullWidth(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text('Queue', style: theme.textTheme.titleMedium),
                                const Spacer(),
                                Text(
                                  queue.isEmpty ? '0/0' : '${currentIndex + 1}/${queue.length}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            Expanded(
                              child: ListView.separated(
                                itemCount: queue.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final s = queue[i];
                                  final isCurrent = i == currentIndex;

                                  final aRaw = (s.artist ?? '').trim();
                                  final a = aRaw.isEmpty || aRaw.toLowerCase() == '<unknown>'
                                      ? artist
                                      : aRaw;

                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                                    leading: SizedBox(
                                      width: 28,
                                      child: Text(
                                        '${i + 1}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isCurrent ? AppTheme.text : AppTheme.textDim,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      s.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: isCurrent
                                          ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
                                          : theme.textTheme.titleMedium,
                                    ),
                                    subtitle: Text(
                                      a,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                                    ),
                                    trailing: isCurrent
                                        ? AnimatedBuilder(
                                            animation: _rainbow,
                                            builder: (context, _) {
                                              final hue = _rainbow.value * 360.0;
                                              final color = HSVColor.fromAHSV(1.0, hue, 0.85, 0.95).toColor();
                                              return FadeTransition(
                                                opacity: Tween<double>(begin: 0.25, end: 1.0).animate(_blink),
                                                child: Icon(Icons.graphic_eq, color: color),
                                              );
                                            },
                                          )
                                        : null,
                                    onTap: () => PlayerController.I.seekToIndex(i),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _fallbackArtworkSmall() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.music_note, size: 54, color: AppTheme.text),
    );
  }
}

/// Marquee 1-liniowy:
/// - działa TYLKO gdy odtwarzanie (pauza = stop w miejscu)
/// - jeśli pingPong=true: oscyluje tam i z powrotem
/// - jeśli tekst się mieści: zwykły Text
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  final double speed; // px/s
  final bool pingPong;
  final Duration edgePause;

  const _MarqueeText(
    this.text, {
    this.style,
    this.speed = 35.0,
    this.pingPong = true,
    this.edgePause = const Duration(milliseconds: 450),
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  StreamSubscription<bool>? _playSub;

  double _textW = 0;
  double _boxW = 0;
  bool _scroll = false;

  bool _playing = false;
  bool _armed = false; // żeby nie odpalać wielokrotnie

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);

    _playSub = PlayerController.I.playingStream.listen((p) {
      _playing = p;
      _syncPlayback();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _recalcAndStart());
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _recalcAndStart();
    }
  }

  @override
  void dispose() {
    _playSub?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _syncPlayback() {
    if (!_scroll) return;

    if (!_playing) {
      // pauza -> zatrzymaj w miejscu
      if (_c.isAnimating) _c.stop();
      return;
    }

    // gra -> jeśli nie animuje, wznow
    if (!_c.isAnimating) {
      // jeżeli było już kiedyś uruchomione, to po prostu jedź dalej (forward/reverse jest w kontrolerze)
      _c.forward(from: _c.value);
    }
  }

  void _recalcAndStart() {
    if (!mounted) return;

    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textW = tp.width;

    if (_boxW <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalcAndStart());
      return;
    }

    final overflow = _textW > _boxW;
    if (!overflow) {
      _scroll = false;
      _armed = false;
      _c.stop();
      _c.reset();
      setState(() {});
      return;
    }

    _scroll = true;

    final distance = (_textW - _boxW);
    final seconds = distance / widget.speed;
    final duration = Duration(milliseconds: (seconds * 1000).round().clamp(800, 60000));

    _c
      ..stop()
      ..reset()
      ..duration = duration;

    if (_armed) {
      setState(() {});
      _syncPlayback();
      return;
    }
    _armed = true;

    Future<void>(() async {
      // start z pauzą na lewej krawędzi
      await Future.delayed(widget.edgePause);
      if (!mounted || !_scroll) return;

      if (!_playing) {
        // jeśli pauza w momencie startu, zostaw na początku
        setState(() {});
        return;
      }

      if (widget.pingPong) {
        // ping-pong: forward do końca, pauza, reverse do początku, pauza, repeat
        // Robimy to bez "repeat(reverse:true)" żeby dać pauzy na końcach.
        while (mounted && _scroll) {
          await _c.forward(from: _c.value);
          if (!mounted || !_scroll) return;
          if (!_playing) {
            _c.stop();
            return;
          }
          await Future.delayed(widget.edgePause);
          if (!mounted || !_scroll) return;
          if (!_playing) {
            _c.stop();
            return;
          }

          await _c.reverse(from: _c.value);
          if (!mounted || !_scroll) return;
          if (!_playing) {
            _c.stop();
            return;
          }
          await Future.delayed(widget.edgePause);
          if (!mounted || !_scroll) return;
          if (!_playing) {
            _c.stop();
            return;
          }
        }
      } else {
        // klasyczne: tylko w lewo i od nowa (bez pauz na końcach)
        await _c.forward(from: 0);
        if (!mounted || !_scroll) return;
        _c.repeat();
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final lineH = (style.fontSize ?? 20) * 1.25;

    return StreamBuilder<bool>(
      stream: PlayerController.I.playingStream,
      builder: (context, snap) {
        _playing = snap.data ?? false;

        return LayoutBuilder(
          builder: (context, c) {
            final newBoxW = c.maxWidth.isFinite ? c.maxWidth : 0.0;
            if ((newBoxW - _boxW).abs() > 0.5) {
              _boxW = newBoxW;
              WidgetsBinding.instance.addPostFrameCallback((_) => _recalcAndStart());
            }

            if (!_scroll) {
              return SizedBox(
                height: lineH,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              );
            }

            return SizedBox(
              height: lineH,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final dx = -((_textW - _boxW) * _c.value);

                    return OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 0,
                      maxWidth: double.infinity,
                      child: Transform.translate(
                        offset: Offset(dx, 0),
                        child: Text(widget.text, style: style, maxLines: 1),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProgressBarFullWidth extends StatelessWidget {
  const _ProgressBarFullWidth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: PlayerController.I.durationStream,
      builder: (context, durSnap) {
        final duration = durSnap.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: PlayerController.I.positionStream,
          builder: (context, posSnap) {
            Duration pos = posSnap.data ?? Duration.zero;
            if (pos > duration) pos = duration;

            final double maxMs =
                duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
            final double valueMs = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Slider(
                  value: valueMs,
                  max: maxMs,
                  onChanged: (v) => PlayerController.I.seek(Duration(milliseconds: v.round())),
                ),
                Row(
                  children: [
                    Text(_fmt(pos), style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    Text(_fmt(duration), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }
}

class _TransportControlsFullWidth extends StatelessWidget {
  const _TransportControlsFullWidth();

  IconData _repeatIcon(HiFiRepeatMode m) {
    return switch (m) {
      HiFiRepeatMode.off => Icons.repeat,
      HiFiRepeatMode.all => Icons.repeat,
      HiFiRepeatMode.one => Icons.repeat_one,
    };
  }

  String _repeatLabel(HiFiRepeatMode m) {
    return switch (m) {
      HiFiRepeatMode.off => 'Repeat off',
      HiFiRepeatMode.all => 'Repeat all',
      HiFiRepeatMode.one => 'Repeat one',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: PlayerController.I.shuffleEnabled,
          builder: (context, enabled, _) {
            return IconButton(
              tooltip: enabled ? 'Shuffle on' : 'Shuffle off',
              onPressed: () => PlayerController.I.setShuffle(!enabled),
              icon: Icon(Icons.shuffle, color: enabled ? AppTheme.text : AppTheme.textDim),
            );
          },
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Previous',
              onPressed: PlayerController.I.previousSmart,
              icon: const Icon(Icons.skip_previous),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: StreamBuilder<bool>(
              stream: PlayerController.I.playingStream,
              builder: (context, snap) {
                final playing = snap.data ?? false;
                return IconButton(
                  tooltip: playing ? 'Pause' : 'Play',
                  onPressed: () => playing ? PlayerController.I.pause() : PlayerController.I.play(),
                  icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  iconSize: 52,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: IconButton(
              tooltip: 'Stop',
              onPressed: PlayerController.I.stop,
              icon: const Icon(Icons.stop),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Next',
              onPressed: PlayerController.I.hasNext ? PlayerController.I.next : null,
              icon: const Icon(Icons.skip_next),
            ),
          ),
        ),
        ValueListenableBuilder<HiFiRepeatMode>(
          valueListenable: PlayerController.I.repeatMode,
          builder: (context, mode, _) {
            final active = mode != HiFiRepeatMode.off;
            return IconButton(
              tooltip: _repeatLabel(mode),
              onPressed: PlayerController.I.cycleRepeat,
              icon: Icon(_repeatIcon(mode), color: active ? AppTheme.text : AppTheme.textDim),
            );
          },
        ),
      ],
    );
  }
}

class _VuMeterRealSlot extends StatelessWidget {
  final double height;
  const _VuMeterRealSlot({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: const _VuMeterPseudoBars());
  }
}

class _VuMeterPseudoBars extends StatefulWidget {
  const _VuMeterPseudoBars();

  @override
  State<_VuMeterPseudoBars> createState() => _VuMeterPseudoBarsState();
}

class _VuMeterPseudoBarsState extends State<_VuMeterPseudoBars> {
  final _rng = Random();
  Timer? _t;
  bool _playing = false;

  double _l = 0.0;
  double _r = 0.0;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_playing) {
        setState(() {
          _l = max(0.0, _l - 0.05);
          _r = max(0.0, _r - 0.05);
        });
        return;
      }
      setState(() {
        _l = _next(_l);
        _r = _next(_r);
      });
    });
  }

  double _next(double v) {
    final bump = _rng.nextDouble() * 0.18;
    final decay = 0.04 + _rng.nextDouble() * 0.06;
    var out = (v - decay + bump).clamp(0.0, 1.0);
    if (_rng.nextDouble() < 0.06) out = min(1.0, out + 0.35);
    return out;
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PlayerController.I.playingStream,
      builder: (context, snap) {
        _playing = snap.data ?? false;

        return Row(
          children: [
            Expanded(child: _VuBar(level: _l)),
            const SizedBox(width: 10),
            Expanded(child: _VuBar(level: _r)),
          ],
        );
      },
    );
  }
}

class _VuBar extends StatelessWidget {
  final double level;
  const _VuBar({required this.level});

  @override
  Widget build(BuildContext context) {
    const segments = 20;
    final onCount = (level * segments).round().clamp(0, segments);

    return Column(
      children: List.generate(segments, (i) {
        final fromBottom = segments - 1 - i;
        final isOn = fromBottom < onCount;

        Color c;
        if (fromBottom >= 19) {
          c = const Color(0xFFE53935);
        } else if (fromBottom >= 17) {
          c = const Color(0xFFFDD835);
        } else {
          c = const Color(0xFF43A047);
        }

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: isOn ? c : AppTheme.surface2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}