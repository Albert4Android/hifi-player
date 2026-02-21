import 'dart:async';
import 'dart:math' as math;

class VuState {
  final double level; // 0..1 (smoothed)
  final double peak;  // 0..1 (peak hold)
  const VuState({required this.level, required this.peak});
}

class VuBallistics {
  VuBallistics({
    required Stream<double> inputLevelStream,
    required Stream<bool> playingStream,
    this.fps = 60,
    this.attackMs = 70,
    this.releaseMs = 420,
    this.peakHoldMs = 650,
    this.peakFallMs = 900,
    this.outputGain = 1.35,
  })  : _input = inputLevelStream,
        _playingStream = playingStream;

  final Stream<double> _input;
  final Stream<bool> _playingStream;

  final int fps;
  final int attackMs;
  final int releaseMs;
  final int peakHoldMs;
  final int peakFallMs;
  final double outputGain;

  StreamSubscription<double>? _subInput;
  StreamSubscription<bool>? _subPlay;
  Timer? _timer;

  final _controller = StreamController<VuState>.broadcast();
  Stream<VuState> get stream => _controller.stream;

  bool _playing = false;

  double _target = 0.0;
  double _level = 0.0;

  double _peak = 0.0;
  int _peakHoldLeftMs = 0;

  bool _running = false;

  void start() {
    if (_running) return;
    _running = true;

    _subPlay = _playingStream.listen((p) {
      _playing = p;
      if (!_playing) _target = 0.0;
    });

    _subInput = _input.listen((raw) {
      if (!_playing) {
        _target = 0.0;
        return;
      }
      final boosted = (raw * outputGain).clamp(0.0, 1.0);
      _target = boosted;
    });

    final dtMs = (1000 / fps).round();
    _timer = Timer.periodic(Duration(milliseconds: dtMs), (_) => _tick(dtMs));
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    _subInput?.cancel();
    _subInput = null;
    _subPlay?.cancel();
    _subPlay = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _tick(int dtMs) {
    final a = _alpha(dtMs, attackMs);
    final r = _alpha(dtMs, releaseMs);

    if (_target >= _level) {
      _level = _level + (_target - _level) * a;
    } else {
      _level = _level + (_target - _level) * r;
    }

    if (_level >= _peak) {
      _peak = _level;
      _peakHoldLeftMs = peakHoldMs;
    } else {
      if (_peakHoldLeftMs > 0) {
        _peakHoldLeftMs = math.max(0, _peakHoldLeftMs - dtMs);
      } else {
        final fallPerMs = 1.0 / math.max(1, peakFallMs);
        _peak = (_peak - fallPerMs * dtMs).clamp(0.0, 1.0);
      }
    }

    _controller.add(VuState(level: _level, peak: _peak));
  }

  double _alpha(int dtMs, int timeConstantMs) {
    final tau = math.max(1.0, timeConstantMs.toDouble());
    final dt = dtMs.toDouble();
    return 1.0 - math.exp(-dt / tau);
  }
}