import 'package:animated_upload_button/animated_check.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

class CircularProgressButton extends StatefulWidget {
  const CircularProgressButton({Key? key}) : super(key: key);

  @override
  State<CircularProgressButton> createState() => _CircularProgressButtonState();
}

class _CircularProgressButtonState extends State<CircularProgressButton>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _uploadIconAnimationController;
  late Animation<Offset> _uploadIconAnimation;
  late AnimationController _doneIconAnimationController;
  late Animation<double> _doneIconAnimation;
  bool isUploaded = false;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _uploadIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _uploadIconAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.7),
    ).animate(_uploadIconAnimationController);

    _doneIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _doneIconAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _doneIconAnimationController,
        curve: Curves.easeInOutCirc,
      ),
    );

    //upload icon status listener
    _uploadIconAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _progressAnimationController
          ..reset()
          ..forward();
      }
    });

    //progress status listener
    _progressAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isUploaded = true;
        });

        //start done animation
        _doneIconAnimationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _progressAnimationController.dispose();
    _uploadIconAnimationController.dispose();
    _doneIconAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        CircularIconButton(
          onTap: () {
            _uploadIconAnimationController
              ..reset()
              ..forward();
          },
          isUploaded: isUploaded,
          uploadAnimation: _uploadIconAnimation,
          doneAnimation: _doneIconAnimation,
        ),
      ],
    );
  }
}

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    Key? key,
    required this.onTap,
    required this.isUploaded,
    required this.uploadAnimation,
    required this.doneAnimation,
  }) : super(key: key);
  final GestureTapCallback onTap;
  final bool isUploaded;
  final Animation<Offset> uploadAnimation;
  final Animation<double> doneAnimation;

  @override
  Widget build(BuildContext context) {
    final icon = isUploaded
        ? Center(
            child: AnimatedCheck(
              progress: doneAnimation,
              size: 150.0,
              color: Colors.white,
            ),
          )
        : SlideTransition(
            position: uploadAnimation,
            child: const Icon(
              Icons.arrow_upward_outlined,
              color: Colors.white,
              size: 32.0,
            ),
          );

    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 60.0,
          width: 60.0,
          decoration: const BoxDecoration(
            color: Color(0xff285EFE),
            shape: BoxShape.circle,
          ),
          child: icon,
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
