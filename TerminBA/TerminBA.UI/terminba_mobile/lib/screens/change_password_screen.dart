import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool _obscureCurrent = true;
  bool _obscureConfirmCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirmNew = true;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }

    final values = formState.value;
    final currentPassword = values['currentPassword'] as String?;
    final confirmCurrentPassword = values['confirmCurrentPassword'] as String?;
    final newPassword = values['newPassword'] as String?;
    final confirmNewPassword = values['confirmNewPassword'] as String?;

    if (currentPassword == null || confirmCurrentPassword == null || newPassword == null || confirmNewPassword == null) {
      return;
    }

    if (newPassword == currentPassword) {
      setState(() {
        _errorMessage = 'New password cannot be the same as the current password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.changePassword(
        currentPassword,
        confirmCurrentPassword,
        newPassword,
        confirmNewPassword,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully. Please log in again.')),
      );
      
      await authProvider.logout();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FormBuilder(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                FormBuilderTextField(
                  name: 'currentPassword',
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Please enter your current password'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'confirmCurrentPassword',
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  obscureText: _obscureConfirmCurrent,
                  decoration: InputDecoration(
                    labelText: 'Confirm Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmCurrent ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmCurrent = !_obscureConfirmCurrent;
                        });
                      },
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Please confirm your current password'),
                    (value) {
                      final currentPassword = _formKey.currentState?.fields['currentPassword']?.value;
                      if (value != currentPassword) {
                        return 'Current passwords do not match';
                      }
                      return null;
                    }
                  ]),
                ),
                const SizedBox(height: 24),
                FormBuilderTextField(
                  name: 'newPassword',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Please enter a password'),
                    FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters'),
                    FormBuilderValidators.match(RegExp(r'[A-Z]'), errorText: 'Password must contain at least one uppercase letter'),
                    FormBuilderValidators.match(RegExp(r'[a-z]'), errorText: 'Password must contain at least one lowercase letter'),
                    FormBuilderValidators.match(RegExp(r'[0-9]'), errorText: 'Password must contain at least one number'),
                    FormBuilderValidators.match(RegExp(r'[!@#\$%\^&\*\(\)_\+=\[{\]};:<>|./?,-]'), errorText: 'Password must contain at least one special character'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'confirmNewPassword',
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  obscureText: _obscureConfirmNew,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmNew = !_obscureConfirmNew;
                        });
                      },
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Please confirm your new password'),
                    (value) {
                      final newPassword = _formKey.currentState?.fields['newPassword']?.value;
                      if (value != newPassword) {
                        return 'New passwords do not match';
                      }
                      return null;
                    }
                  ]),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading || !(_formKey.currentState?.isValid ?? false) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Change Password', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
