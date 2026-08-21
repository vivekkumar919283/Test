import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';

class AdvancedCameraService {
  late CameraController _controller;
  final List<CameraDescription> cameras;
  bool isRecording = false;
  Function? onFrameCallback;
  Function? onMotionDetected;

  AdvancedCameraService({required this.cameras});

  Future<void> initialize() async {
    if (cameras.isEmpty) return;
    
    // Keep device awake
    await WakelockPlus.enable();
    
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    await _controller.initialize();
    
    // Start streaming frames for processing
    _controller.startImageStream((CameraImage image) {
      onFrameCallback?.call(image);
    });
  }

  Future<void> startContinuousRecording(String outputPath) async {
    try {
      await _controller.startVideoRecording();
      isRecording = true;
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      final video = await _controller.stopVideoRecording();
      isRecording = false;
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  void dispose() {
    WakelockPlus.disable();
    _controller.dispose();
  }
}

class AdvancedMicrophoneService {
  late FlutterSoundRecorder _recorder;
  bool isRecording = false;
  StreamSubscription? _levelSubscription;
  Function? onAudioLevel;
  Function? onAudioDataReceived;
  Timer? _recordingTimer;

  AdvancedMicrophoneService() {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> initialize() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      throw 'Microphone permission denied';
    }
    
    await _recorder.openRecorder();
    
    // Keep device awake during recording
    await WakelockPlus.enable();
  }

  Future<void> startContinuousRecording(String outputPath) async {
    try {
      await _recorder.startRecorder(
        toFile: outputPath,
        codec: Codec.pcm16,
        sampleRate: 16000,
      );
      
      isRecording = true;
      
      // Monitor recording level
      _levelSubscription = _recorder.onProgress!.listen((event) {
        onAudioLevel?.call(event.decibels);
      });
      
      // Auto-restart recording every 30 minutes to prevent file size issues
      _recordingTimer = Timer.periodic(Duration(minutes: 30), (timer) async {
        await stopRecording();
        await startContinuousRecording(outputPath);
      });
    } catch (e) {
      print('Error starting microphone recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      await _levelSubscription?.cancel();
      await _recordingTimer?.cancel();
      await _recorder.stopRecorder();
      isRecording = false;
    } catch (e) {
      print('Error stopping microphone recording: $e');
    }
  }

  Future<void> dispose() async {
    await WakelockPlus.disable();
    await _recorder.closeRecorder();
  }
}

class SystemControlService {
  static const platform = MethodChannel('com.jarvis.ai/system');

  // Get all running applications
  Future<List<String>> getRunningApps() async {
    try {
      final List result = await platform.invokeMethod('getRunningApps');
      return result.cast<String>();
    } catch (e) {
      print('Error getting running apps: $e');
      return [];
    }
  }

  // Launch an application by package name or app name
  Future<void> launchApp(String appName) async {
    try {
      await platform.invokeMethod('launchApp', {'appName': appName});
    } catch (e) {
      print('Error launching app: $e');
    }
  }

  // Close an application
  Future<void> closeApp(String appName) async {
    try {
      await platform.invokeMethod('closeApp', {'appName': appName});
    } catch (e) {
      print('Error closing app: $e');
    }
  }

  // Get device screen resolution
  Future<Map<String, int>> getScreenResolution() async {
    try {
      final result = await platform.invokeMethod('getScreenResolution');
      return {
        'width': result['width'] as int,
        'height': result['height'] as int,
      };
    } catch (e) {
      print('Error getting screen resolution: $e');
      return {'width': 0, 'height': 0};
    }
  }

  // Take screenshot
  Future<String?> takeScreenshot() async {
    try {
      final result = await platform.invokeMethod('takeScreenshot');
      return result as String?;
    } catch (e) {
      print('Error taking screenshot: $e');
      return null;
    }
  }

  // Get device info
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await platform.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting device info: $e');
      return {};
    }
  }

  // Control system volume
  Future<void> setVolume(double volume) async {
    try {
      await platform.invokeMethod('setVolume', {'volume': volume});
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Control screen brightness
  Future<void> setBrightness(double brightness) async {
    try {
      await platform.invokeMethod('setBrightness', {'brightness': brightness});
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  // Lock device
  Future<void> lockDevice() async {
    try {
      await platform.invokeMethod('lockDevice');
    } catch (e) {
      print('Error locking device: $e');
    }
  }

  // Unlock device
  Future<void> unlockDevice() async {
    try {
      await platform.invokeMethod('unlockDevice');
    } catch (e) {
      print('Error unlocking device: $e');
    }
  }
}