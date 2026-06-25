import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

// ── Mock roles ────────────────────────────────────────────────────────────────
enum _Role { student, teacher, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  _Role _selectedRole = _Role.student;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    switch (_selectedRole) {
      case _Role.admin:
        context.go(AppRoutes.adminHome);
      case _Role.teacher:
        context.go(AppRoutes.teacherHome);
      default:
        context.go(AppRoutes.studentHome);
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
          _buildIdField(),
          const SizedBox(height: 14),
          _buildPasswordField(),
          const SizedBox(height: 14),
          _buildRememberRow(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildRoleDivider(),
          const SizedBox(height: 16),
          _buildRoleSelector(),
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

  Widget _buildIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student ID / Employee ID', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 6),
        TextField(
          controller: _idController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter your ID',
            prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textLabel),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _onLogin,
        icon: const Icon(Icons.login, size: 20),
        label: const Text('Login'),
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('SELECT YOUR ROLE', style: AppTextStyles.label),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _Role.values.map((role) {
        final isActive = _selectedRole == role;
        final label = role.name[0].toUpperCase() + role.name.substring(1);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryNavy : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                  color: isActive ? AppColors.primaryNavy : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isActive ? AppColors.textWhite : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
