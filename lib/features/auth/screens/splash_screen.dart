import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;

  // ── mock status messages ──────────────────────────────────────────────────
  final List<String> _statusMessages = [
    'INITIALIZING ACADEMIC PORTAL...',
    'LOADING STUDENT DATA...',
    'READY',
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.95, curve: Curves.easeInOut),
    );

    _controller.addListener(_onAnimationTick);
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(AppRoutes.login);
      }
    });
  }

  void _onAnimationTick() {
    final v = _controller.value;
    final newIndex = v < 0.4 ? 0 : v < 0.8 ? 1 : 2;
    if (newIndex != _messageIndex) {
      setState(() => _messageIndex = newIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildTagline(),
              const Spacer(flex: 4),
              _buildProgressSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── sections ──────────────────────────────────────────────────────────────

  Widget _buildBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.splashDark, AppColors.splashLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Image.asset(
        'assets/images/beltei_logo.png',
        width: 160,
        height: 160,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Text(
        'BELTEI Campus',
        style: AppTextStyles.h1White.copyWith(fontSize: 22, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Text(
        'QUALITY · EFFICIENCY · EXCELLENCE · MORALITY · VIRTUE',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accentGold,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _statusMessages[_messageIndex],
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.0,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
