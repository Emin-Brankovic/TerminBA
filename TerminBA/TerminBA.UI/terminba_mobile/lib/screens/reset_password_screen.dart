import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;
  bool _isTokenExpired = false;

  Future<void> _resetPassword() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }

    final values = formState.value;
    final email = values['email']?.toString().trim() ?? '';
    final token = values['token']?.toString().trim() ?? '';
    final newPassword = values['newPassword']?.toString() ?? '';
    final confirmNewPassword = values['confirmNewPassword']?.toString() ?? '';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isTokenExpired = false;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.confirmPasswordReset(
        email,
        token,
        newPassword,
        confirmNewPassword,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF00C875)),
              SizedBox(width: 8),
              Text('Success'),
            ],
          ),
          content: const Text('Your password has been successfully reset. You can now log in with your new password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Go to Login', style: TextStyle(color: Color(0xFF00C875), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      var message = e.toString();
      if (message.contains('Exception:')) {
        message = message.replaceAll('Exception:', '').trim();
      }

      final isExpired = message.toLowerCase().contains('expired');
      setState(() {
        _isTokenExpired = isExpired;
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Reset Password',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: const Color(0xFF00C875),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check your email inbox for the 6-digit verification code and enter it below.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_isTokenExpired) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Request a new reset code'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade800,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  FormBuilderTextField(
                    name: 'email',
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, size: 22),
                      hintText: 'Email Address',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Email is required'),
                      FormBuilderValidators.email(errorText: 'Please enter a valid email address'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'token',
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key_outlined, size: 22),
                      hintText: '6-digit Reset Code',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Reset code is required'),
                      FormBuilderValidators.minLength(6, errorText: 'Code must be at least 6 digits'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'newPassword',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: !_showNewPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 22),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                        icon: Icon(
                          _showNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 22,
                        ),
                      ),
                      hintText: 'New Password',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'New password is required'),
                      FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters'),
                      FormBuilderValidators.match(RegExp(r'[A-Z]'), errorText: 'Must contain at least one uppercase letter'),
                      FormBuilderValidators.match(RegExp(r'[a-z]'), errorText: 'Must contain at least one lowercase letter'),
                      FormBuilderValidators.match(RegExp(r'[0-9]'), errorText: 'Must contain at least one number'),
                      FormBuilderValidators.match(RegExp(r'[!@#\$%\^&\*\(\)_\+=\[{\]};:<>|./?,-]'), errorText: 'Must contain at least one special character'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'confirmNewPassword',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: !_showConfirmPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 22),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 22,
                        ),
                      ),
                      hintText: 'Confirm New Password',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Please confirm your new password'),
                      (value) {
                        final newPassword = _formKey.currentState?.fields['newPassword']?.value;
                        if (value != newPassword) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ]),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Reset Password'),
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
