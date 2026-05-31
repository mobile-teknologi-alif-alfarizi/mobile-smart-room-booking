import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();

  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (currentPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Password saat ini tidak boleh kosong';
      });
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Password baru tidak boleh kosong';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'Password baru minimal 6 karakter';
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Konfirmasi password tidak boleh kosong';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Password baru dan konfirmasi tidak sesuai';
      });
      return;
    }

    if (currentPassword == newPassword) {
      setState(() {
        _errorMessage = 'Password baru tidak boleh sama dengan password saat ini';
      });
      return;
    }

    _submitChangePassword(currentPassword, newPassword);
  }

  Future<void> _submitChangePassword(String currentPassword, String newPassword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _successMessage = 'Password berhasil diubah';
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah'),
          backgroundColor: AppColors.accent,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Ubah Password',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Text(
                        'Pastikan password yang Anda buat kuat dan mudah diingat. Gunakan kombinasi huruf besar, huruf kecil, angka, dan simbol.',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 24 : 28),

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: isMobile ? 18 : 20,
                      ),
                      SizedBox(width: isMobile ? 10 : 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
              ],

              // Success Message
              if (_successMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.accent,
                        size: isMobile ? 18 : 20,
                      ),
                      SizedBox(width: isMobile ? 10 : 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
              ],

              // Current Password Field
              _buildPasswordLabel('Password Saat Ini', isMobile),
              SizedBox(height: isMobile ? 8 : 10),
              _buildPasswordField(
                controller: _currentPasswordController,
                hint: 'Masukkan password saat ini',
                obscureText: !_showCurrentPassword,
                onShowPasswordToggle: () {
                  setState(() {
                    _showCurrentPassword = !_showCurrentPassword;
                  });
                },
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // New Password Field
              _buildPasswordLabel('Password Baru', isMobile),
              SizedBox(height: isMobile ? 8 : 10),
              _buildPasswordField(
                controller: _newPasswordController,
                hint: 'Masukkan password baru',
                obscureText: !_showNewPassword,
                onShowPasswordToggle: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 8 : 10),
              _buildPasswordStrengthIndicator(
                _newPasswordController.text,
                isMobile,
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Confirm Password Field
              _buildPasswordLabel('Konfirmasi Password', isMobile),
              SizedBox(height: isMobile ? 8 : 10),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: 'Konfirmasi password baru',
                obscureText: !_showConfirmPassword,
                onShowPasswordToggle: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                isMobile: isMobile,
              ),
              if (_confirmPasswordController.text.isNotEmpty &&
                  _newPasswordController.text.isNotEmpty) ...[
                SizedBox(height: isMobile ? 8 : 10),
                Row(
                  children: [
                    Icon(
                      _newPasswordController.text ==
                              _confirmPasswordController.text
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: _newPasswordController.text ==
                              _confirmPasswordController.text
                          ? AppColors.accent
                          : AppColors.error,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      _newPasswordController.text ==
                              _confirmPasswordController.text
                          ? 'Password sesuai'
                          : 'Password tidak sesuai',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: _newPasswordController.text ==
                                _confirmPasswordController.text
                            ? AppColors.accent
                            : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: isMobile ? 28 : 32),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.borderLight,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: isMobile ? 18 : 20,
                          width: isMobile ? 18 : 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Ubah Password',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordLabel(String label, bool isMobile) {
    return Text(
      label,
      style: TextStyle(
        fontSize: isMobile ? 12 : 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onShowPasswordToggle,
    required bool isMobile,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: isMobile ? 12 : 13,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 12 : 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColors.textSecondary,
            size: isMobile ? 18 : 20,
          ),
          onPressed: onShowPasswordToggle,
        ),
      ),
      style: TextStyle(
        fontSize: isMobile ? 12 : 13,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password, bool isMobile) {
    String strength = 'Lemah';
    Color strengthColor = AppColors.error;

    if (password.length >= 8) {
      strength = 'Kuat';
      strengthColor = AppColors.accent;
    } else if (password.length >= 6) {
      strength = 'Sedang';
      strengthColor = AppColors.warning;
    }

    return Row(
      children: [
        Text(
          'Kekuatan: ',
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: isMobile ? 4 : 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (password.length / 12).clamp(0, 1),
                child: Container(
                  height: isMobile ? 4 : 5,
                  decoration: BoxDecoration(
                    color: strengthColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Text(
          strength,
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
