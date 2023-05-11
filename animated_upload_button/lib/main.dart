import 'package:flutter/material.dart';
import 'dart:math' show pi;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Upload Button',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _uploadIconAnimationController;
  late Animation<Offset> _uploadIconAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _uploadIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _uploadIconAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _uploadIconAnimationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _progressAnimationController.dispose();
    _uploadIconAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 69.0,
                child: AnimatedBuilder(
                    animation: _progressAnimationController,
                    builder: (context, child) {
                      final progress = _progressAnimationController.value;
                      return progress != 1
                          ? CustomPaint(
                              painter: CompletionRingPainter(
                                progress: _progressAnimationController.value,
                              ),
                            )
                          : const SizedBox();
                    }),
              ),
              InkWell(
                onTap: () {
                  _progressAnimationController
                    ..reset()
                    ..forward();
                },
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: const BoxDecoration(
                    color: Color(0xff285EFE),
                    shape: BoxShape.circle,
                  ),
                  child: SlideTransition(
                    position: _uploadIconAnimation,
                    child: const Icon(
                      Icons.arrow_upward_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletionRingPainter extends CustomPainter {
  const CompletionRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // configure the paint and drawing properties
    final strokeWidth = size.width / 15.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    //create and configure the ring paint
    final ringPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth
      ..color = const Color(0xff7395FF)
      ..style = PaintingStyle.stroke;

    // draw an arc that starts from the top (-pi / 2)
    // and sweeps and angle of (2 * pi * progress)
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -pi / 2,
      2 * pi * progress,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
