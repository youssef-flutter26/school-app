import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app_user.dart';
import '../../services/api_client.dart';

class OtpVerificationScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser? user;
  final ValueChanged<AppUser>? onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.api,
    this.user,
    this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '919000000001');
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // خطوة إرسال الـ OTP
  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await widget.api.sendOtp(
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isBusy = false;
          // وضع الكود التجريبي تلقائياً لتسهيل التجربة
          _otpController.text = '123456';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully! (Use code: 123456)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          // حتى لو السيرفر جاب ريت ليميت أو خطأ، هنخلي السيستم يفتح ويظهر حقل الـ OTP للتجربة
          _isOtpSent = true;
          _isBusy = false;
          _otpController.text = '123456';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isBusy = false;
          _otpController.text = '123456';
        });
      }
    }
  }

  // خطوة التحقق من الـ OTP والانتقال للهوم
  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.trim() != '123456') {
      setState(() {
        _errorMessage = 'Invalid OTP code. Please use 123456';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() => _isBusy = false);

        final defaultUser = widget.user ??
            AppUser(
              id: 1,
              name: 'Sunrise School Admin',
              email: 'admin@sunrise.demo',
              role: 'school_admin',
            );

        if (widget.onVerified != null) {
          widget.onVerified!(defaultUser);
        }

        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(defaultUser);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Verification failed.';
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        backgroundColor: const Color(0xFF246BCE),
        foregroundColor: Colors.white,
      ),
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
                    const Text(
                      'Verification / OTP',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A43),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Verify your mobile number via WhatsApp OTP code to complete login.',
                      style: TextStyle(color: Color(0xFF61758A), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isOtpSent,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: 'Enter phone number',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter mobile number';
                        }
                        if (v.trim().length < 10 || v.trim().length > 13) {
                          return 'Mobile number must be valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_isOtpSent) ...[
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'OTP Verification Code',
                          prefixIcon: Icon(Icons.security),
                          hintText: 'Enter 123456',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter OTP code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed: _isBusy
                          ? null
                          : (_isOtpSent ? _handleVerifyOtp : _handleSendOtp),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF246BCE),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                          : Text(
                              _isOtpSent ? 'Verify OTP Code' : 'Send OTP',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
