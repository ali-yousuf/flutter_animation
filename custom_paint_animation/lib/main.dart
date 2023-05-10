import 'dart:math' show pi;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

extension on VoidCallback {
  Future<void> delayed(Duration duration) => Future.delayed(duration, this);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: -(pi / 2.0),
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.bounceOut,
    ));

    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.bounceOut,
      ),
    );

    //rotation status listener
    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: _flipAnimationController,
            curve: Curves.bounceOut,
          ),
        );
        //reset the flip controller and start the animation
        _flipAnimationController
          ..reset()
          ..forward();
      }
    });

    //flip status listener
    _flipAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotationAnimation = Tween<double>(
          begin: _rotationAnimation.value,
          end: _rotationAnimation.value + -(pi / 2.0),
        ).animate(CurvedAnimation(
          parent: _rotationController,
          curve: Curves.bounceOut,
        ));

        _rotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _rotationController.dispose();
    _flipAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rotationController
      ..reset()
      ..forward.delayed(
        const Duration(
          seconds: 1,
        ),
      );

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(
                  _rotationAnimation.value,
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                      animation: _flipAnimationController,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..rotateY(
                              _flipAnimation.value,
                            ),
                          child: ClipPath(
                            clipper: LeftHalfCircleClipper(),
                            child: Container(
                              height: 100,
                              width: 100,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }),
                  AnimatedBuilder(
                      animation: _flipAnimationController,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..rotateY(
                              _flipAnimation.value,
                            ),
                          child: ClipPath(
                            clipper: RightHalfCircleClipper(),
                            child: Container(
                              height: 100,
                              width: 100,
                              color: Colors.yellow,
                            ),
                          ),
                        );
                      }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class LeftHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    //move pencil to end of the width
    path.moveTo(size.width, 0);
    //end at
    var offset = Offset(size.width, size.height);
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(
        size.width / 2,
        size.height / 2,
      ),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class RightHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    var offset = Offset(0, size.height);
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(
        size.width / 2,
        size.height / 2,
      ),
      clockwise: true,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
