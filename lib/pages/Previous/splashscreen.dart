import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mod_maneger_v3/pages/Previous/land_page.dart';
import 'package:mod_maneger_v3/pages/admin/admin_home.dart';
import 'package:mod_maneger_v3/pages/modaretor/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.purpleAccent,
    ).animate(_controller);

    // Start login check after animation initializes
    Future.delayed(Duration.zero, () => _checkLoginStatus());
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    final userType = prefs.getString('user');

    try {
      if (email != null && password != null) {
        // Try Firebase login
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          // Navigate based on user type
          _navigateBasedOnUserType(userType ?? 'user');
          return;
        }
      }
    } catch (e) {
      print('Login error: $e');
    }

    // If any failure occurs, go to landing page
    _navigateToLandingPage();
  }

  void _navigateBasedOnUserType(String userType) {
    Widget targetPage;
    switch (userType.toLowerCase()) {
      case 'admin':
        targetPage = AdminHome();
        break;
      case 'mod':
        targetPage = Home();
        break;
      default:
        targetPage = LandPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  void _navigateToLandingPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandPage()),
    );
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
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_animation.value!, _animation.value!.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  RotationTransition(
                    turns: _controller,
                    child: const Icon(
                      Icons.security,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Animated text
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Checking Security...',
                        textStyle: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        colors: [
                          Colors.white,
                          Colors.blue,
                          Colors.purple,
                        ],
                      ),
                    ],
                    isRepeatingAnimation: true,
                  ),
                  const SizedBox(height: 20),
                  // Loading dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ScaleTransition(
                          scale: _controller.drive(
                            TweenSequence([
                              TweenSequenceItem(
                                tween: Tween(begin: 0.5, end: 1.5),
                                weight: 1,
                              ),
                              TweenSequenceItem(
                                tween: Tween(begin: 1.5, end: 0.5),
                                weight: 1,
                              ),
                            ]),
                          ),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

