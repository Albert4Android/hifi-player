package com.example.hifi_player

import android.media.audiofx.Visualizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {

    private val CHANNEL = "vu_meter_stream"

    private var visualizer: Visualizer? = null
    private var sink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    sink = events
                    start()
                }

                override fun onCancel(arguments: Any?) {
                    stop()
                    sink = null
                }
            })
    }

    private fun start() {
        if (visualizer != null) return

        try {
            val v = Visualizer(0)

            val range = Visualizer.getCaptureSizeRange()
            v.captureSize = range[1]

            v.setDataCaptureListener(
                object : Visualizer.OnDataCaptureListener {
                    override fun onWaveFormDataCapture(
                        visualizer: Visualizer?,
                        waveform: ByteArray?,
                        samplingRate: Int
                    ) {
                        if (waveform == null || waveform.isEmpty()) {
                            sink?.success(0.0)
                            return
                        }

                        var sum = 0.0
                        for (b in waveform) {
                            val x = b.toDouble()
                            sum += x * x
                        }
                        val rms = sqrt(sum / waveform.size)
                        val level = (rms / 128.0).coerceIn(0.0, 1.0)

                        sink?.success(level)
                    }

                    override fun onFftDataCapture(
                        visualizer: Visualizer?,
                        fft: ByteArray?,
                        samplingRate: Int
                    ) {
                        // unused for now
                    }
                },
                Visualizer.getMaxCaptureRate() / 2,
                true,
                false
            )

            v.enabled = true
            visualizer = v

        } catch (_: Exception) {
            sink?.success(0.0)
            visualizer = null
        }
    }

    private fun stop() {
        try {
            visualizer?.enabled = false
            visualizer?.release()
        } catch (_: Exception) {
        } finally {
            visualizer = null
        }
    }

    override fun onDestroy() {
        stop()
        super.onDestroy()
    }
}
