import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/model/city.dart';
import 'package:terminba_admin_desktop/model/user.dart';
import 'package:terminba_admin_desktop/model/user_update_request.dart';
import 'package:terminba_admin_desktop/providers/auth_provider.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/user_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  late AuthProvider _authProvider;
  late UserProvider _userProvider;
  late CityProvider _cityProvider;

  User? _currentUser;
  List<City> _cities = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = context.read<AuthProvider>();
    _userProvider = context.read<UserProvider>();
    _cityProvider = context.read<CityProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _currentUserId = await _authProvider.getCurrentUserId();

      final cityFuture = _cityProvider.get();
      final userFuture = _currentUserId != null
          ? _userProvider.getById(_currentUserId!)
          : Future.value(null);

      final cityResult = await cityFuture;
      final user = await userFuture;

      setState(() {
        _cities = (cityResult.items ?? []).cast<City>();
        _currentUser = user;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load profile: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    if (_currentUserId == null) return;

    final values = _formKey.currentState!.value;
    final emailValue =
      (values['email'] as String?)?.trim().isNotEmpty == true
        ? values['email'] as String
        : _currentUser!.email;

    setState(() => _isSaving = true);
    try {
      final request = UserUpdateRequest(
        values['firstName'] as String,
        values['lastName'] as String,
        values['username'] as String,
        emailValue,
        values['phoneNumber'] as String?,
        null,
        values['birthDate'] as DateTime,
        values['cityId'] as int,
      );

      await _userProvider.update(_currentUserId!, request.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        // Reload to reflect saved data
        await _loadData();
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Admin Profile',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? const Center(child: Text('Could not load profile.'))
          : _buildProfileForm(),
    );
  }

  Widget _buildProfileForm() {
    final user = _currentUser!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  FormBuilder(
                    key: _formKey,
                    initialValue: {
                      'firstName': user.firstName,
                      'lastName': user.lastName,
                      'username': user.username,
                      'email': user.email,
                      'phoneNumber': user.phoneNumber,
                      'birthDate': user.birthDate,
                      'cityId': user.cityId,
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'firstName',
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.minLength(2),
                                  FormBuilderValidators.maxLength(50),
                                ]),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'lastName',
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.minLength(2),
                                  FormBuilderValidators.maxLength(50),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'username',
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.minLength(3),
                                  FormBuilderValidators.maxLength(30),
                                ]),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'email',
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.email(),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'phoneNumber',
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.phoneNumber(),
                                ]),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderDateTimePicker(
                                name: 'birthDate',
                                inputType: InputType.date,
                                decoration: const InputDecoration(
                                  labelText: 'Birth Date',
                                  border: OutlineInputBorder(),
                                ),
                                lastDate: DateTime.now(),
                                validator: FormBuilderValidators.required(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FormBuilderDropdown<int>(
                          name: 'cityId',
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          items: _cities
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          validator: FormBuilderValidators.required(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving…' : 'Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
