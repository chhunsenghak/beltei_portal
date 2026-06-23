import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _idController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _onSubmit() => setState(() => _submitted = true);

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _submitted ? _buildSuccessCard() : _buildFormCard(),
          ),
        ),
      ),
    );
  }

  // ── form card ──────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const SizedBox(height: 24),
          _buildIcon(),
          const SizedBox(height: 20),
          _buildHeading(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 28),
          _buildIdField(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 20),
          _buildBackToLogin(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textSecondary),
          Text('Back', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.lock_reset, color: AppColors.primaryNavy, size: 30),
    );
  }

  Widget _buildHeading() {
    return Text('Forgot Password', style: AppTextStyles.h1);
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter your Student ID or Employee ID and we\'ll send reset instructions to your registered email.',
      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
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
          decoration: const InputDecoration(
            hintText: 'Enter your ID',
            prefixIcon: Icon(Icons.badge_outlined, size: 20, color: AppColors.textLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: _onSubmit,
        child: Text('Send Reset Instructions', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: GestureDetector(
        onTap: () => context.pop(),
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.body,
            children: [
              TextSpan(
                text: 'Remember your password? ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextSpan(text: 'Back to Login', style: AppTextStyles.link),
            ],
          ),
        ),
      ),
    );
  }

  // ── success card ───────────────────────────────────────────────────────────

  Widget _buildSuccessCard() {
    return _Card(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildSuccessIcon(),
          const SizedBox(height: 20),
          Text('Check Your Email', style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Reset instructions have been sent to your registered email address.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: Text('Back to Login', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.statusGreenBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.mark_email_read_outlined, color: AppColors.statusGreen, size: 36),
    );
  }
}

// ── Shared card container ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: child,
    );
  }
}
