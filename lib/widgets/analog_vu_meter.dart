import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../services/vu_ballistics.dart';

class AnalogVuMeter extends StatefulWidget {
  const AnalogVuMeter({
    super.key,
    this.height = 170,
    this.gap = 16,
  });

  final double height;
  final double gap;

  @override
  State<AnalogVuMeter> createState() => _AnalogVuMeterState();
}

class _AnalogVuMeterState extends State<AnalogVuMeter> {
  late final VuBallistics _ballisticsL;
  late final VuBallistics _ballisticsR;

  @override
  void initState() {
    super.initState();

    // L i R: minimalnie różna balistyka, żeby wyglądało “stereo”
    _ballisticsL = VuBallistics(outputGain: 1.35, attackMs: 80, releaseMs: 460, peakHoldMs: 700, peakFallMs: 900);
    _ballisticsR = VuBallistics(outputGain: 1.35, attackMs: 95, releaseMs: 430, peakHoldMs: 700, peakFallMs: 900);

    _ballisticsL.start();
    _ballisticsR.start();
  }

  @override
  void dispose() {
    _ballisticsL.dispose();
    _ballisticsR.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _SingleVu(
              stream: _ballisticsL.stream,
              label: 'L',
            ),
          ),
          SizedBox(width: widget.gap),
          Expanded(
            child: _SingleVu(
              stream: _ballisticsR.stream,
              label: 'R',
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleVu extends StatelessWidget {
  const _SingleVu({required this.stream, required this.label});

  final Stream<VuState> stream;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VuState>(
      stream: stream,
      builder: (context, snap) {
        final s = snap.data ?? const VuState(level: 0.0, peak: 0.0);

        return CustomPaint(
          painter: _VuPainter(
            level: s.level,
            peak: s.peak,
            label: label,
          ),
        );
      },
    );
  }
}

class _VuPainter extends CustomPainter {
  _VuPainter({
    required this.level,
    required this.peak,
    required this.label,
  });

  final double level; // 0..1
  final double peak;  // 0..1
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Panel
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(14),
    );

    final panelPaint = Paint()..color = const Color(0xFF0B0B0B);
    canvas.drawRRect(r, panelPaint);

    // Inner bezel
    final bezelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF2A2A2A);
    canvas.drawRRect(r.deflate(2), bezelPaint);

    // Meter geometry
    final center = Offset(w / 2, h * 0.92);
    final radius = math.min(w, h) * 0.88;

    // Arc from left to right (classic VU)
    final startAngle = math.pi * 1.08; // left-ish
    final sweepAngle = math.pi * 0.84; // to right-ish
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Scale background
    final scaleBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF121212);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, scaleBg);

    // Ticks
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFB8B8B8);

    final minorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF6F6F6F);

    // 0..1 mapped to arc
    // We'll draw ticks in dB-like positions: -20..+3 (approx)
    // Just a visual mapping: more dense near the top.
    for (int i = 0; i <= 28; i++) {
      final t = i / 28.0; // 0..1
      final eased = _easeVuScale(t);
      final ang = startAngle + sweepAngle * eased;

      final isMajor = (i % 4 == 0);
      final len = isMajor ? radius * 0.10 : radius * 0.06;

      final p1 = _polar(center, radius * 0.86, ang);
      final p2 = _polar(center, radius * 0.86 - len, ang);

      canvas.drawLine(p1, p2, isMajor ? tickPaint : minorPaint);
    }

    // Label L/R
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFFCFCFCF),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(10, 10));

    // Needle
    final needleAngle = startAngle + sweepAngle * _easeVuScale(level.clamp(0.0, 1.0));
    _drawNeedle(canvas, center, radius, needleAngle);

    // Peak marker (small dot on arc)
    final peakAngle = startAngle + sweepAngle * _easeVuScale(peak.clamp(0.0, 1.0));
    final peakPos = _polar(center, radius * 0.80, peakAngle);
    final peakPaint = Paint()..color = const Color(0xFFE14B4B);
    canvas.drawCircle(peakPos, 3.2, peakPaint);

    // Bottom “glass” highlight
    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0x22FFFFFF),
          Color(0x00000000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(r, glow);
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius, double ang) {
    final hubR = radius * 0.03;

    final needleLen = radius * 0.78;
    final p2 = _polar(center, needleLen, ang);

    final needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE6E6E6);

    canvas.drawLine(center, p2, needlePaint);

    final hubPaint = Paint()..color = const Color(0xFF2D2D2D);
    canvas.drawCircle(center, hubR * 1.6, hubPaint);

    final hubInner = Paint()..color = const Color(0xFFB0B0B0);
    canvas.drawCircle(center, hubR, hubInner);
  }

  Offset _polar(Offset c, double r, double a) {
    return Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
  }

  double _easeVuScale(double t) {
    // “VU feel”: szybciej rośnie w dole, wolniej przy końcówce (jak skala dB)
    // t in 0..1
    final x = t.clamp(0.0, 1.0);
    return math.pow(x, 0.55).toDouble(); // sublinear
  }

  @override
  bool shouldRepaint(covariant _VuPainter old) {
    return old.level != level || old.peak != peak || old.label != label;
  }
}
