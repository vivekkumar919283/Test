import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/system_monitor_service.dart';
import '../services/advanced_system_service.dart';

class SystemControlScreen extends StatefulWidget {
  const SystemControlScreen({Key? key}) : super(key: key);

  @override
  State<SystemControlScreen> createState() => _SystemControlScreenState();
}

class _SystemControlScreenState extends State<SystemControlScreen> {
  late SystemMonitorService _monitorService;
  List<String> runningApps = [];
  bool isMonitoringActive = false;

  @override
  void initState() {
    super.initState();
    _monitorService = SystemMonitorService();
    _loadRunningApps();
  }

  Future<void> _loadRunningApps() async {
    final systemControl = SystemControlService();
    final apps = await systemControl.getRunningApps();
    setState(() {
      runningApps = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Control'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monitoring Status Card
              Card(
                color: Colors.grey.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '24/7 Monitoring',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: isMonitoringActive,
                            activeColor: Colors.green,
                            onChanged: (value) async {
                              if (value) {
                                await _monitorService.startBackgroundMonitoring();
                              } else {
                                await _monitorService.stopBackgroundMonitoring();
                              }
                              setState(() {
                                isMonitoringActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.mic, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          const Text('Microphone: '),
                          Text(
                            _monitorService.isRunning ? 'Recording' : 'Off',
                            style: TextStyle(
                              color: _monitorService.isRunning
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.videocam, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          const Text('Camera: '),
                          Text(
                            _monitorService.isRunning ? 'Recording' : 'Off',
                            style: TextStyle(
                              color: _monitorService.isRunning
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _QuickActionButton(
                    icon: Icons.screenshot,
                    label: 'Screenshot',
                    onTap: () async {
                      final systemControl = SystemControlService();
                      await systemControl.takeScreenshot();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Screenshot taken')),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.brightness_4,
                    label: 'Brightness',
                    onTap: () async {
                      final systemControl = SystemControlService();
                      await systemControl.setBrightness(0.5);
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.volume_down,
                    label: 'Mute',
                    onTap: () async {
                      final systemControl = SystemControlService();
                      await systemControl.setVolume(0);
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.lock,
                    label: 'Lock Device',
                    onTap: () async {
                      final systemControl = SystemControlService();
                      await systemControl.lockDevice();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Running Applications
              const Text(
                'Running Applications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: runningApps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(runningApps[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        final systemControl = SystemControlService();
                        await systemControl.closeApp(runningApps[index]);
                        _loadRunningApps();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _monitorService.dispose();
    super.dispose();
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade400),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade400),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}