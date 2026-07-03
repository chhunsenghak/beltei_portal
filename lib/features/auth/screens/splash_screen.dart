import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/app_user.dart';

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

  int _messageIndex = 0;

  List<String> _statusMessages(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [l.splashInitializing, l.splashLoadingData, l.splashReady];
  }

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

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        final authService = AuthService();
        if (authService.currentSession != null) {
          final user = await authService.getProfile();
          if (!mounted) return;
          switch (user?.role) {
            case UserRole.admin:
              context.go(AppRoutes.adminHome);
            case UserRole.teacher:
              context.go(AppRoutes.teacherHome);
            default:
              context.go(AppRoutes.studentHome);
          }
        } else {
          context.go(AppRoutes.login);
        }
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
        AppLocalizations.of(context)!.appTitle,
        style: AppTextStyles.h1White.copyWith(fontSize: 22, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Text(
        AppLocalizations.of(context)!.splashTagline,
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
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _statusMessages(context)[_messageIndex],
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
