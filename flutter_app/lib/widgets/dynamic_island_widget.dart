import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wake_word_detection_service.dart';

class DynamicIslandWidget extends StatefulWidget {
  final bool isActive;

  const DynamicIslandWidget({Key? key, required this.isActive}) : super(key: key);

  @override
  State<DynamicIslandWidget> createState() => _DynamicIslandWidgetState();
}

class _DynamicIslandWidgetState extends State<DynamicIslandWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DynamicIslandWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 30 + (_expandAnimation.value * 70),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                        Colors.purple.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      15 + (_expandAnimation.value * 10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 20 * _expandAnimation.value,
                        spreadRadius: 5 * _expandAnimation.value,
                      ),
                    ],
                  ),
                  child: _expandAnimation.value < 0.5
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPulsingDot(),
                              const SizedBox(width: 8),
                              const Text(
                                'Jarvis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '🎤 Jarvis Listening',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildAudioWaveform(),
                            const SizedBox(height: 12),
                            Consumer<WakeWordDetectionService>(
                              builder: (context, service, _) {
                                return Text(
                                  service.lastRecognizedText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingDot() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0, 1, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.1 * index,
                  0.1 * index + 0.6,
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            child: Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class JarvisActivationOverlay extends StatefulWidget {
  const JarvisActivationOverlay({Key? key}) : super(key: key);

  @override
  State<JarvisActivationOverlay> createState() =>
      _JarvisActivationOverlayState();
}

class _JarvisActivationOverlayState extends State<JarvisActivationOverlay> {
  @override
  void initState() {
    super.initState();
    // Listen for Jarvis activation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WakeWordDetectionService>().onJarvisActivated = () {
        _showActivationAnimation();
      };
    });
  }

  void _showActivationAnimation() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.purple.shade600,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.8),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🎤',
                style: TextStyle(fontSize: 64),
              ),
              SizedBox(height: 16),
              Text(
                'Jarvis Active',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WakeWordDetectionService>(
      builder: (context, service, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(),
            ),
            if (service.isJarvisActive)
              DynamicIslandWidget(isActive: service.isJarvisActive),
          ],
        );
      },
    );
  }
}