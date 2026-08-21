import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WakeWordDetectionService extends ChangeNotifier {
  late SpeechToText _speechToText;
  late FlutterTts _tts;
  
  bool isListening = false;
  bool isJarvisActive = false;
  String wakeWord = 'jarvis';
  double activationConfidence = 0.0;
  
  String lastRecognizedText = '';
  Function? onJarvisActivated;
  Function? onJarvisDeactivated;
  Function? onCommandReceived;

  WakeWordDetectionService() {
    _speechToText = SpeechToText();
    _tts = FlutterTts();
  }

  Future<void> initialize() async {
    try {
      // Request permissions
      await Permission.microphone.request();
      await Permission.camera.request();
      await Permission.notification.request();
      
      // Keep device awake
      await WakelockPlus.enable();
      
      // Initialize speech recognition
      bool available = await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      
      if (!available) {
        print('Speech recognition not available');
        return;
      }
      
      // Initialize TTS
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.9);
      await _tts.setPitch(1.0);
      
      // Start continuous listening
      _startContinuousListening();
      
      print('✅ Wake Word Detection Service Initialized');
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  void _startContinuousListening() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!isJarvisActive) {
        _listenForWakeWord();
      }
    });
  }

  Future<void> _listenForWakeWord() async {
    if (isListening) return;
    
    try {
      isListening = true;
      notifyListeners();
      
      await _speechToText.listen(
        onResult: (result) {
          lastRecognizedText = result.recognizedWords.toLowerCase();
          
          // Check if wake word detected
          if (lastRecognizedText.contains(wakeWord)) {
            activationConfidence = result.confidence;
            _activateJarvis();
          }
          
          print('Recognized: $lastRecognizedText (confidence: ${result.confidence})');
        },
        listenFor: Duration(seconds: 2),
        pauseFor: Duration(seconds: 1),
      );
    } catch (e) {
      print('Error listening for wake word: $e');
    } finally {
      isListening = false;
      notifyListeners();
    }
  }

  Future<void> _activateJarvis() async {
    try {
      isJarvisActive = true;
      notifyListeners();
      
      // Trigger callback
      onJarvisActivated?.call();
      
      // Play activation sound
      await _tts.speak('Jarvis activated');
      
      // Show visual indicator
      _showDynamicIsland();
      
      // Listen for command
      await _listenForCommand();
      
    } catch (e) {
      print('Error activating Jarvis: $e');
    }
  }

  Future<void> _listenForCommand() async {
    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            String command = result.recognizedWords.toLowerCase();
            onCommandReceived?.call(command);
            _processCommand(command);
          }
        },
        listenFor: Duration(seconds: 10),
      );
    } catch (e) {
      print('Error listening for command: $e');
    }
  }

  Future<void> _processCommand(String command) async {
    try {
      // Send to backend or process locally
      print('Processing command: $command');
      
      // Example responses
      String response = 'I heard: $command';
      await _tts.speak(response);
      
      // Deactivate after command
      await Future.delayed(Duration(seconds: 2));
      _deactivateJarvis();
      
    } catch (e) {
      print('Error processing command: $e');
    }
  }

  void _showDynamicIsland() {
    // This will be implemented in the UI layer
    print('🟢 Dynamic Island Activated');
  }

  void _deactivateJarvis() {
    isJarvisActive = false;
    onJarvisDeactivated?.call();
    notifyListeners();
  }

  @override
  void dispose() async {
    await WakelockPlus.disable();
    await _speechToText.stop();
    await _tts.stop();
    super.dispose();
  }
}