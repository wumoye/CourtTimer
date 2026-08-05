package com.wumoye.courttimer

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var duckingFocusRequest: AudioFocusRequest? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.wumoye.courttimer/vibration",
        ).setMethodCallHandler { call, result ->
            if (call.method != "pauseResume") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (!vibrator.hasVibrator()) {
                result.success(false)
                return@setMethodCallHandler
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    VibrationEffect.createOneShot(60, VibrationEffect.DEFAULT_AMPLITUDE),
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(60)
            }
            result.success(true)
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.wumoye.courttimer/audio_focus",
        ).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            when (call.method) {
                "requestDucking" -> {
                    val attributes = AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                    val requestResult = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        duckingFocusRequest = AudioFocusRequest.Builder(
                            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK,
                        )
                            .setAudioAttributes(attributes)
                            .setOnAudioFocusChangeListener { }
                            .build()
                        audioManager.requestAudioFocus(duckingFocusRequest!!)
                    } else {
                        @Suppress("DEPRECATION")
                        audioManager.requestAudioFocus(
                            null,
                            AudioManager.STREAM_MUSIC,
                            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK,
                        )
                    }
                    result.success(requestResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
                }
                "abandonDucking" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        duckingFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
                        duckingFocusRequest = null
                    } else {
                        @Suppress("DEPRECATION")
                        audioManager.abandonAudioFocus(null)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
