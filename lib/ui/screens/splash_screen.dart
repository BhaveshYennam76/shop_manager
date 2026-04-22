import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_manager/core/theme/app_theme.dart';
import 'package:shop_manager/ui/screens/home_screen.dart';
import 'package:shop_manager/ui/screens/login_screen.dart';

/// Splash screen — shown on launch while auth is resolved.
/// Performs anonymous sign-in if no user is logged in, then navigates to Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _logoController.forward();
    if (!mounted) return;
    await _textController.forward();
    if (!mounted) return;
    await _handleAuth();
  }

  /// Checks if a user session exists, then navigates accordingly.
  Future<void> _handleAuth() async {
    final auth = FirebaseAuth.instance;
    final isLoggedIn = auth.currentUser != null;

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (isLoggedIn) {
      _navigateTo(const HomeScreen());
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => screen,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }


  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              _buildOrb(top: -80, right: -80, size: 260,
                  color: AppTheme.primary.withOpacity(0.18)),
              _buildOrb(bottom: -60, left: -60, size: 220,
                  color: AppTheme.accent.withOpacity(0.12)),
              _buildOrb(top: 180, left: 30, size: 120,
                  color: AppTheme.primaryLight.withOpacity(0.08)),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary
                                    .withOpacity(0.35 * _pulse.value),
                                blurRadius: 60 * _pulse.value,
                                spreadRadius: 10 * _pulse.value,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: AppTheme.buttonShadow,
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: Text(
                                'My Shops',
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your shops with ease',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 72),

                    FadeTransition(
                      opacity: _textOpacity,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textHint,
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

  Widget _buildOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
