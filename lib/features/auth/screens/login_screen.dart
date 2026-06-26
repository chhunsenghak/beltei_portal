import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../models/app_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.signIn(email: email, password: password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.user != null) {
      switch (result.user!.role) {
        case UserRole.admin:
          context.go(AppRoutes.adminHome);
        case UserRole.teacher:
          context.go(AppRoutes.teacherHome);
        case UserRole.student:
          context.go(AppRoutes.studentHome);
      }
    } else {
      setState(() => _errorMessage = result.error ?? 'Login failed');
    }
  }

  void _onForgotPassword() {
    context.push(AppRoutes.forgotPassword);
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  // ── card ───────────────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 28),
          _buildEmailField(),
          const SizedBox(height: 14),
          _buildPasswordField(),
          const SizedBox(height: 14),
          _buildRememberRow(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildError(),
          ],
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildSupportRow(),
        ],
      ),
    );
  }

  // ── sections ───────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/beltei_logo.png',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle() {
    return Text(
      'Welcome to BELTEI\nCampus',
      textAlign: TextAlign.center,
      style: AppTextStyles.h1.copyWith(
        color: AppColors.primaryNavy,
        height: 1.3,
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppColors.textLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textLabel),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textLabel,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberRow() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
            activeColor: AppColors.primaryNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text('Remember Me', style: AppTextStyles.body),
        const Spacer(),
        GestureDetector(
          onTap: _onForgotPassword,
          child: Text('Forgot Password?', style: AppTextStyles.link),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusRedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.statusRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.statusRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 20),
                  SizedBox(width: 8),
                  Text('Login'),
                ],
              ),
      ),
    );
  }

  Widget _buildSupportRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Need help? ', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Text('Contact Support', style: AppTextStyles.link),
      ],
    );
  }
}
