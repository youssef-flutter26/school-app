import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/api_client.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.api,
    this.onSignedIn,
  });

  final ApiClient? api;
  final ValueChanged<AppUser>? onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // وضع بيانات الاعتماد الافتراضية للتجربة السريعة
  final _email = TextEditingController(text: 'parent@sunrise.demo');
  final _password = TextEditingController(text: 'SchoolRide@123');

  bool _obscure = true;
  String? _error;
  bool _isBusy = false;

  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.api ?? ApiClient();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });

    try {
      final user = await _apiClient.login(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (mounted) {
        setState(() => _isBusy = false);

        // الانتقال المباشر لشاشة الـ OTP بعد تسجيل الدخول لتأكيد الهاتف بالتوكن
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              api: _apiClient,
              user: user,
              onVerified: widget.onSignedIn,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isBusy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to sign in. Please check your credentials.';
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 76,
                      width: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFF246BCE),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.directions_bus_rounded,
                          color: Colors.white, size: 42),
                    ),
                    const SizedBox(height: 24),
                    const Text('Welcome to SchoolRide',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF102A43))),
                    const SizedBox(height: 8),
                    const Text(
                        'Safer journeys. Clearer updates. Peace of mind.',
                        style:
                            TextStyle(color: Color(0xFF61758A), fontSize: 15)),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.alternate_email)),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your email'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your password'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isBusy ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF246BCE),
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Sign in',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
