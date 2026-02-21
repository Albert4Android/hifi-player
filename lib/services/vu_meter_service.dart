import 'package:flutter/services.dart';

class VuMeterService {
  VuMeterService._();

  static const EventChannel _channel = EventChannel('vu_meter_stream');

  /// 0.0..1.0 (RMS normalized from Android Visualizer)
  static Stream<double> get levelStream {
    return _channel.receiveBroadcastStream().map((dynamic event) {
      if (event is double) return event;
      if (event is int) return event.toDouble();
      return 0.0;
    });
  }
}