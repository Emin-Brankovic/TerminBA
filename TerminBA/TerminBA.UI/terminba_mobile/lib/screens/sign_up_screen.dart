import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:terminba_mobile/model/city.dart';
import 'package:terminba_mobile/model/user_insert_request.dart';
import 'package:terminba_mobile/providers/city_provider.dart';
import 'package:terminba_mobile/providers/user_provider.dart';

class SignUpScreen extends StatefulWidget {
	const SignUpScreen({super.key});

	@override
	State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
	final _formKey = GlobalKey<FormBuilderState>();
	final _cityProvider = CityProvider();
	final _userProvider = UserProvider();

	bool _isLoading = false;
	bool _isLoadingLookups = true;
	bool _showPassword = false;
	String? _lookupError;
	List<City> _cities = [];

	@override
	void initState() {
		super.initState();
		_loadLookups();
	}

	Future<void> _loadLookups() async {
		setState(() {
			_isLoadingLookups = true;
			_lookupError = null;
		});

		try {
			final results = await Future.wait([
				_cityProvider.get(),
			]);

			final cities = (results[0].items ?? []).cast<City>();

			if (!mounted) return;
			setState(() {
				_cities = cities;
				_lookupError = null;
			});
		} on Exception catch (e) {
			if (!mounted) return;
			var message = e.toString();
			if (message.contains('Exception:')) {
				message = message.replaceAll('Exception:', '').trim();
			}
			setState(() {
				_lookupError = message.isEmpty ? 'Failed to load lookups.' : message;
			});
		} catch (e) {
			if (!mounted) return;
			setState(() {
				_lookupError = 'Failed to load lookups.';
			});
		} finally {
			if (!mounted) return;
			setState(() {
				_isLoadingLookups = false;
			});
		}
	}

	Future<void> _submit() async {
		final formState = _formKey.currentState;
		if (formState == null) return;

		if (!formState.saveAndValidate()) {
			return;
		}

		final values = formState.value;

		final request = UserInsertRequest(
			firstName: values['firstName'],
			lastName: values['lastName'],
			username: values['username'],
			email: values['email'],
			phoneNumber: values['phoneNumber'],
			instagramAccount: values['instagramAccount'],
			password: values['password'],
			birthDate: values['birthDate'],
			cityId: values['cityId'],
			roleId: 1,
		);

		setState(() {
			_isLoading = true;
		});

		try {
			await _userProvider.insert(request.toJson());

			if (!mounted) return;
			await _showMessage(
				title: 'Success',
				message: 'Account created. You can log in now.',
			);
			Navigator.pop(context);
		} on Exception catch (e) {
			if (!mounted) return;
			var message = e.toString();
			if (message.contains('Exception:')) {
				message = message.replaceAll('Exception:', '').trim();
			}
			await _showMessage(title: 'Sign Up Failed', message: message);
		} catch (e) {
			if (!mounted) return;
			await _showMessage(
				title: 'Error',
				message: 'An unexpected error occurred: ${e.toString()}',
			);
		} finally {
			if (!mounted) return;
			setState(() {
				_isLoading = false;
			});
		}
	}

	Future<void> _showMessage({
		required String title,
		required String message,
	}) {
		return showDialog<void>(
			context: context,
			builder: (context) => AlertDialog(
				title: Text(title),
				content: Text(message),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('OK'),
					),
				],
			),
		);
	}

	String? _optionalPhoneValidator(String? value) {
		if (value == null || value.trim().isEmpty) {
			return null;
		}
		return FormBuilderValidators.phoneNumber()(value);
	}

	String? _confirmPasswordValidator(String? value) {
		final password = _formKey.currentState?.fields['password']?.value as String?;
		if (value == null || value.isEmpty) {
			return 'Confirm your password.';
		}
		if (password != value) {
			return 'Passwords do not match.';
		}
		return null;
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final isLookupReady = !_isLoadingLookups && _lookupError == null;

		return Scaffold(
			appBar: AppBar(
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new),
					onPressed: () => Navigator.pop(context),
				),
			),
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
						child: FormBuilder(
							key: _formKey,
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									Text(
										'Sign - Up',
										style: theme.textTheme.displayLarge?.copyWith(
											color: const Color(0xFF00C875),
											fontSize: 34,
											fontWeight: FontWeight.w800,
										),
									),
									const SizedBox(height: 24),
									FormBuilderTextField(
										name: 'firstName',
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.person_outline, size: 22),
											hintText: 'First Name',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										validator: FormBuilderValidators.compose([
											FormBuilderValidators.required(),
											FormBuilderValidators.minLength(2),
											FormBuilderValidators.maxLength(50),
										]),
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'lastName',
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.person_outline, size: 22),
											hintText: 'Last Name',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										validator: FormBuilderValidators.compose([
											FormBuilderValidators.required(),
											FormBuilderValidators.minLength(2),
											FormBuilderValidators.maxLength(50),
										]),
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'username',
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.person_outline, size: 22),
											hintText: 'Username',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										validator: FormBuilderValidators.compose([
											FormBuilderValidators.required(),
											FormBuilderValidators.minLength(3),
											FormBuilderValidators.maxLength(30),
										]),
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'email',
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.email_outlined, size: 22),
											hintText: 'Email',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										keyboardType: TextInputType.emailAddress,
										validator: FormBuilderValidators.compose([
											FormBuilderValidators.required(),
											FormBuilderValidators.email(),
										]),
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'phoneNumber',
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.phone_outlined, size: 22),
											hintText: 'Contact Number',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										keyboardType: TextInputType.phone,
										validator: _optionalPhoneValidator,
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'instagramAccount',
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.alternate_email, size: 22),
											hintText: 'Instagram (optional)',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
									),
									const SizedBox(height: 14),
									FormBuilderDateTimePicker(
										name: 'birthDate',
										inputType: InputType.date,
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.cake_outlined, size: 22),
											hintText: 'Birth Date',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										validator: FormBuilderValidators.required(),
									),
									const SizedBox(height: 14),
									FormBuilderDropdown<int>(
										name: 'cityId',
										enabled: isLookupReady,
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.location_city_outlined, size: 22),
											hintText: 'City',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										items: _cities
												.map(
													(city) => DropdownMenuItem<int>(
														value: city.id,
														child: Text(city.name),
													),
												)
												.toList(),
										validator: FormBuilderValidators.required(),
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'password',
										obscureText: !_showPassword,
										decoration: InputDecoration(
											prefixIcon: const Icon(Icons.lock_outline, size: 22),
											hintText: 'Password',
											contentPadding: const EdgeInsets.symmetric(
												horizontal: 18,
												vertical: 18,
											),
											suffixIcon: IconButton(
												onPressed: _isLoading
														? null
														: () {
															setState(() {
																_showPassword = !_showPassword;
															});
														},
												icon: Icon(
													_showPassword
															? Icons.visibility_outlined
															: Icons.visibility_off_outlined,
													size: 22,
												),
											),
										),
										validator: FormBuilderValidators.compose([
											FormBuilderValidators.required(),
											FormBuilderValidators.minLength(6),
										]),
									),
									const SizedBox(height: 14),
									FormBuilderTextField(
										name: 'confirmPassword',
										obscureText: true,
										decoration: const InputDecoration(
											prefixIcon: Icon(Icons.lock_outline, size: 22),
											hintText: 'Confirm Password',
											contentPadding:
													EdgeInsets.symmetric(horizontal: 18, vertical: 18),
										),
										validator: _confirmPasswordValidator,
									),
									const SizedBox(height: 18),
									if (_isLoadingLookups)
										const Padding(
											padding: EdgeInsets.only(bottom: 10),
											child: CircularProgressIndicator(strokeWidth: 2),
										),
									if (_lookupError != null)
										Padding(
											padding: const EdgeInsets.only(bottom: 10),
											child: Column(
												children: [
													Text(
														_lookupError!,
														style: theme.textTheme.bodyMedium?.copyWith(
															color: Colors.red,
														),
														textAlign: TextAlign.center,
													),
													const SizedBox(height: 6),
													TextButton(
														onPressed: _isLoadingLookups ? null : _loadLookups,
														child: const Text('Retry'),
													),
												],
											),
										),
									const SizedBox(height: 8),
									SizedBox(
										width: double.infinity,
										child: ElevatedButton(
											onPressed:
													_isLoading || _isLoadingLookups ? null : _submit,
											style: ElevatedButton.styleFrom(
												padding: const EdgeInsets.symmetric(vertical: 16),
												textStyle: const TextStyle(fontSize: 16),
											),
											child: _isLoading
													? const SizedBox(
															height: 18,
															width: 18,
															child: CircularProgressIndicator(strokeWidth: 2),
														)
													: const Text('Sign-Up'),
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

