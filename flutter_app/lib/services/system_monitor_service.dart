import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import '../services/advanced_system_service.dart';

class PermissionsManager {
  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.location,
      Permission.photos,
      Permission.videos,
      Permission.calendar,
      Permission.contacts,
      Permission.sensors,
      Permission.storage,
      Permission.mediaLibrary,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
    ].request();

    print('Permission statuses: $statuses');
    return statuses.values.every((status) => status.isGranted);
  }

  static Future<void> showPermissionsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Jarvis Permissions Required'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Jarvis needs the following permissions to function:'),
                SizedBox(height: 16),
                PermissionItem(
                  icon: Icons.mic,
                  title: 'Microphone',
                  description: 'To listen to voice commands 24/7',
                ),
                PermissionItem(
                  icon: Icons.videocam,
                  title: 'Camera',
                  description: 'For screen capture and visual processing',
                ),
                PermissionItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  description: 'For weather and location-based services',
                ),
                PermissionItem(
                  icon: Icons.folder,
                  title: 'Storage',
                  description: 'To access files and save data',
                ),
                PermissionItem(
                  icon: Icons.phone_android,
                  title: 'Device Info',
                  description: 'To monitor system resources',
                ),
                PermissionItem(
                  icon: Icons.battery_std,
                  title: 'Battery Optimization',
                  description: 'To keep running in background',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Deny'),
            ),
            TextButton(
              onPressed: () async {
                await requestAllPermissions();
                Navigator.of(context).pop();
              },
              child: const Text('Allow All'),
            ),
          ],
        );
      },
    );
  }
}

class PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SystemMonitorService {
  late AdvancedCameraService _cameraService;
  late AdvancedMicrophoneService _microphoneService;
  late SystemControlService _systemControl;

  bool _isRunning = false;

  Future<void> startBackgroundMonitoring() async {
    if (_isRunning) return;

    try {
      _isRunning = true;

      // Start camera 24/7
      final cameras = await availableCameras();
      _cameraService = AdvancedCameraService(cameras: cameras);
      await _cameraService.initialize();
      await _cameraService.startContinuousRecording('/storage/emulated/0/jarvis_recordings/video.mp4');

      // Start microphone 24/7
      _microphoneService = AdvancedMicrophoneService();
      await _microphoneService.initialize();
      await _microphoneService.startContinuousRecording('/storage/emulated/0/jarvis_recordings/audio.wav');

      // Initialize system control
      _systemControl = SystemControlService();

      print('✅ Background monitoring started');
    } catch (e) {
      print('❌ Error starting background monitoring: $e');
      _isRunning = false;
    }
  }

  Future<void> stopBackgroundMonitoring() async {
    if (!_isRunning) return;

    try {
      await _cameraService.stopRecording();
      await _microphoneService.stopRecording();
      _cameraService.dispose();
      await _microphoneService.dispose();
      _isRunning = false;
      print('✅ Background monitoring stopped');
    } catch (e) {
      print('❌ Error stopping background monitoring: $e');
    }
  }

  bool get isRunning => _isRunning;

  void dispose() async {
    await stopBackgroundMonitoring();
  }
}