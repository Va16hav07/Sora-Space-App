import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _orbitController;
  late AnimationController _transformController;
  late AnimationController _loadingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _orbitAnimation;
  late Animation<double> _transformAnimation;

  // For star particles
  final List<StarParticle> _stars = [];
  final Random _random = Random();

  Timer? _navigationTimer;
  bool _disposed = false;
  bool _starsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Generate stars with default values - will update in didChangeDependencies
    _initializeStars(400, 800); // default width and height

    // Text fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Orbit animation
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _orbitAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_orbitController);

    // Transform animation (orbit to icon)
    _transformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _transformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_transformController);

    // Loading animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // We need to schedule this after the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        _startAnimationSequence();

        // Navigate to login after splash
        _navigationTimer = Timer(const Duration(milliseconds: 2800), () {
          if (!_disposed && mounted && context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      }
    });
  }

  void _initializeStars(double width, double height) {
    _stars.clear();
    for (int i = 0; i < 50; i++) {
      _stars.add(
        StarParticle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          size: _random.nextDouble() * 2 + 0.5,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Safe to use MediaQuery here
    if (!_starsInitialized) {
      final screenSize = MediaQuery.of(context).size;
      _initializeStars(screenSize.width, screenSize.height);
      _starsInitialized = true;
    }
  }

  void _startAnimationSequence() async {
    if (_disposed) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (_disposed) return;
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (_disposed) return;
    _transformController.forward();
  }

  @override
  void dispose() {
    _disposed = true;
    _navigationTimer?.cancel();
    _fadeController.dispose();
    _orbitController.dispose();
    _transformController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [const Color(0xFF0A1128), const Color(0xFF000000)]
                    : [const Color(0xFFE8F1F2), const Color(0xFFC2D3E2)],
          ),
        ),
        child: Stack(
          children: [
            // Star particles
            if (isDarkMode)
              CustomPaint(
                painter: StarPainter(stars: _stars),
                size: Size(screenSize.width, screenSize.height),
              ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with orbit animation
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orbiting element
                        AnimatedBuilder(
                          animation: _orbitAnimation,
                          builder: (context, child) {
                            return AnimatedBuilder(
                              animation: _transformAnimation,
                              builder: (context, child) {
                                final orbitProgress = _transformAnimation.value;

                                // When transformAnimation progresses, reduce orbit size
                                final orbitRadius =
                                    70 * (1 - orbitProgress * 0.7);

                                return Transform.translate(
                                  offset: Offset(
                                    cos(_orbitAnimation.value) * orbitRadius,
                                    sin(_orbitAnimation.value) * orbitRadius,
                                  ),
                                  child: Opacity(
                                    opacity: 1 - orbitProgress,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color:
                                            isDarkMode
                                                ? Colors.blueAccent
                                                : Colors.indigo,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDarkMode
                                                    ? Colors.blueAccent
                                                    : Colors.indigo)
                                                .withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 7,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // House with VR Icon that appears during transform
                        AnimatedBuilder(
                          animation: _transformAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _transformAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isDarkMode
                                              ? Colors.blueAccent.withOpacity(
                                                0.2,
                                              )
                                              : Colors.indigo.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.05),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.home,
                                      size: 42,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.indigo,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.view_in_ar,
                                        size: 20,
                                        color:
                                            isDarkMode
                                                ? Colors.blueAccent
                                                : Colors.indigoAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Fading text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Sora Space",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        color: isDarkMode ? Colors.white : Colors.indigo,
                        shadows: [
                          Shadow(
                            color:
                                isDarkMode
                                    ? Colors.blueAccent.withOpacity(0.5)
                                    : Colors.indigo.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    // Loading text with shimmer effect
                    ShimmerText(
                      controller: _loadingController,
                      text: "Loading...",
                      baseColor:
                          isDarkMode
                              ? Colors.white70
                              : Colors.indigo.withOpacity(0.7),
                      highlightColor: isDarkMode ? Colors.white : Colors.indigo,
                    ),

                    const SizedBox(height: 20),

                    // Progress bar - adding animation
                    SizedBox(
                      width: 200,
                      child: AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _loadingController.value,
                            valueColor: AlwaysStoppedAnimation(
                              isDarkMode ? Colors.blueAccent : Colors.indigo,
                            ),
                            backgroundColor:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Star particle class for background
class StarParticle {
  double x;
  double y;
  double size;

  StarParticle({required this.x, required this.y, required this.size});
}

// Star painter for background
class StarPainter extends CustomPainter {
  final List<StarParticle> stars;

  StarPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;

    for (var star in stars) {
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Shimmer text effect
class ShimmerText extends StatelessWidget {
  final AnimationController controller;
  final String text;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerText({
    required this.controller,
    required this.text,
    required this.baseColor,
    required this.highlightColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = sin(controller.value * pi * 2);
        final color = Color.lerp(baseColor, highlightColor, value.abs())!;

        return Text(
          text,
          style: TextStyle(color: color, fontSize: 16, letterSpacing: 1.5),
        );
      },
    );
  }
}
