import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  late TextEditingController _nomorIndukController;
  late TextEditingController _passwordController;
  
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nomorIndukController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nomorIndukController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(
        nomorInduk: _nomorIndukController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Check if user role is dosen or mahasiswa
      final userRole = await _authService.getUserRole();
      if (userRole != 'dosen' && userRole != 'mahasiswa') {
        setState(() {
          _errorMessage = 'Akses ditolak. Hanya dosen dan mahasiswa yang dapat login.';
          _isLoading = false;
        });
        return;
      }

      // Login successful
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD4E4F7),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card Container with Wave
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 8,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Curved Blue Section with Wave
                        Stack(
                          children: [
                            // Blue background with gradient
                            Container(
                              width: double.infinity,
                              height: 140,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFB8D8F0),
                                    Color(0xFFA0CCE8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                            ),
                            // Logo centered
                            Positioned(
                              top: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/logo_ruangin.png',
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 70,
                                        width: 70,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.home,
                                          color: AppColors.white,
                                          size: 36,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Wave at bottom using CustomPaint
                            Positioned(
                              bottom: -2,
                              left: 0,
                              right: 0,
                              child: CustomPaint(
                                size: const Size(double.infinity, 30),
                                painter: WavePainter(),
                              ),
                            ),
                          ],
                        ),
                        // Form Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Login Title
                                Text(
                                  'Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 32,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(height: 32),

                                // Error Message
                                if (_errorMessage != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorSurface,
                                      border: Border.all(
                                        color: AppColors.error,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                // Nomor Induk Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'Nomor Induk',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                    TextFormField(
                                      controller: _nomorIndukController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan nomor induk',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textTertiary,
                                          fontSize: 14,
                                        ),
                                        border: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.borderLight,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.error,
                                            width: 1,
                                          ),
                                        ),
                                        focusedErrorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.error,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nomor induk tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Password Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'Password',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan password',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textTertiary,
                                          fontSize: 14,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: AppColors.textSecondary,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                        ),
                                        border: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.borderLight,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.error,
                                            width: 1,
                                          ),
                                        ),
                                        focusedErrorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.error,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password tidak boleh kosong';
                                        }
                                        if (value.length < 6) {
                                          return 'Password minimal 6 karakter';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.black,
                                      foregroundColor: AppColors.white,
                                      disabledBackgroundColor: AppColors.disabled,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Log In',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

// Custom Wave Painter
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.25, 20, size.width * 0.5, 20);
    path.quadraticBezierTo(size.width * 0.75, 20, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => false;
}
