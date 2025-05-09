import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isBrokerSelected = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [const Color(0xFF0A1128), const Color(0xFF001F54)]
                    : [const Color(0xFFF8F5F2), const Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Theme toggle and top bar
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          // Toggle theme callback would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Theme toggle clicked'),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logo with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Logo container - reusing design from splash screen
                          Container(
                            width: 100,
                            height: 100,
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
                                          ? Colors.blueAccent.withOpacity(0.2)
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
                                      isDarkMode ? Colors.white : Colors.indigo,
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
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

                          const SizedBox(height: 16),

                          Text(
                            "Sora Space",
                            style: TextStyle(
                              fontSize: 28,
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
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Role selection tabs
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          // Customer tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isBrokerSelected) {
                                  setState(() {
                                    _isBrokerSelected = false;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color:
                                      !_isBrokerSelected
                                          ? (isDarkMode
                                              ? Colors.blueAccent.withOpacity(
                                                0.3,
                                              )
                                              : Colors.indigo.withOpacity(0.1))
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      !_isBrokerSelected
                                          ? Border.all(
                                            color:
                                                isDarkMode
                                                    ? Colors.blueAccent
                                                        .withOpacity(0.5)
                                                    : Colors.indigo.withOpacity(
                                                      0.2,
                                                    ),
                                            width: 1,
                                          )
                                          : null,
                                  boxShadow:
                                      !_isBrokerSelected
                                          ? [
                                            BoxShadow(
                                              color:
                                                  isDarkMode
                                                      ? Colors.blueAccent
                                                          .withOpacity(0.2)
                                                      : Colors.indigo
                                                          .withOpacity(0.1),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                          : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_rounded,
                                      color:
                                          !_isBrokerSelected
                                              ? (isDarkMode
                                                  ? Colors.white
                                                  : Colors.indigo)
                                              : (isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Customer',
                                      style: TextStyle(
                                        fontWeight:
                                            !_isBrokerSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            !_isBrokerSelected
                                                ? (isDarkMode
                                                    ? Colors.white
                                                    : Colors.indigo)
                                                : (isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Broker tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isBrokerSelected) {
                                  setState(() {
                                    _isBrokerSelected = true;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color:
                                      _isBrokerSelected
                                          ? (isDarkMode
                                              ? Colors.blueAccent.withOpacity(
                                                0.3,
                                              )
                                              : Colors.indigo.withOpacity(0.1))
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      _isBrokerSelected
                                          ? Border.all(
                                            color:
                                                isDarkMode
                                                    ? Colors.blueAccent
                                                        .withOpacity(0.5)
                                                    : Colors.indigo.withOpacity(
                                                      0.2,
                                                    ),
                                            width: 1,
                                          )
                                          : null,
                                  boxShadow:
                                      _isBrokerSelected
                                          ? [
                                            BoxShadow(
                                              color:
                                                  isDarkMode
                                                      ? Colors.blueAccent
                                                          .withOpacity(0.2)
                                                      : Colors.indigo
                                                          .withOpacity(0.1),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                          : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business,
                                      color:
                                          _isBrokerSelected
                                              ? (isDarkMode
                                                  ? Colors.white
                                                  : Colors.indigo)
                                              : (isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Broker',
                                      style: TextStyle(
                                        fontWeight:
                                            _isBrokerSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            _isBrokerSelected
                                                ? (isDarkMode
                                                    ? Colors.white
                                                    : Colors.indigo)
                                                : (isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login form
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor:
                                  isDarkMode
                                      ? Colors.blueAccent
                                      : Colors.indigo,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.white30
                                            : Colors.black26,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.blueAccent
                                            : Colors.indigo,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              cursorColor:
                                  isDarkMode
                                      ? Colors.blueAccent
                                      : Colors.indigo,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.white30
                                            : Colors.black26,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.blueAccent
                                            : Colors.indigo,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.blueAccent
                                            : Colors.indigo,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Biometric authentication option
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Biometric authentication would go here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Biometric authentication requested',
                                      ),
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? Colors.black.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            isDarkMode
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.fingerprint,
                                    size: 32,
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.indigo,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Login button
                            LoginButton(isDarkMode: isDarkMode),

                            const SizedBox(height: 24),

                            // Register link
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Register clicked'),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Register",
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.blueAccent
                                                : Colors.indigo,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Animated login button with gradient
class LoginButton extends StatefulWidget {
  final bool isDarkMode;

  const LoginButton({required this.isDarkMode, super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color:
                    widget.isDarkMode
                        ? Colors.blueAccent.withOpacity(0.3)
                        : Colors.indigo.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment(cos(_animation.value), sin(_animation.value)),
              end: Alignment(
                cos(_animation.value + pi),
                sin(_animation.value + pi),
              ),
              colors:
                  widget.isDarkMode
                      ? [
                        Colors.blueAccent,
                        Colors.blue[700]!,
                        Colors.indigo[800]!,
                        Colors.blueAccent,
                      ]
                      : [
                        Colors.indigo,
                        Colors.indigo[700]!,
                        Colors.indigo[900]!,
                        Colors.indigo,
                      ],
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              // Login logic would go here
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
