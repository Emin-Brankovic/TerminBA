import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import 'package:terminba_mobile/model/city.dart';
import 'package:terminba_mobile/model/user.dart';
import 'package:terminba_mobile/model/user_update_request.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/city_provider.dart';
import 'package:terminba_mobile/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
	final ScrollController? scrollController;
	final bool showBackButton;

	const ProfileScreen({
		super.key,
		this.scrollController,
		this.showBackButton = true,
	});

	@override
	State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
	final _formKey = GlobalKey<FormBuilderState>();
	final _cityProvider = CityProvider();
	final _userProvider = UserProvider();

	bool _isLoading = false;
	bool _isLoadingLookups = true;
	String? _loadError;
	List<City> _cities = [];
	User? _user;

	@override
	void initState() {
		super.initState();
		_loadProfile();
	}

	Future<void> _loadProfile() async {
		setState(() {
			_isLoadingLookups = true;
			_loadError = null;
		});

		try {
			final authProvider = context.read<AuthProvider>();
			final userId = await authProvider.getCurrentUserId();
			if (userId == null) {
				throw Exception('Unable to load user profile.');
			}

			final cityResult = await _cityProvider.get();
			final cities = (cityResult.items ?? []).cast<City>();
			final user = await _userProvider.getById(userId);

			if (!mounted) return;
			setState(() {
				_cities = cities;
				_user = user;
			});
		} on Exception catch (e) {
			if (!mounted) return;
			var message = e.toString();
			if (message.contains('Exception:')) {
				message = message.replaceAll('Exception:', '').trim();
			}
			setState(() {
				_loadError = message.isEmpty ? 'Failed to load profile.' : message;
			});
		} catch (_) {
			if (!mounted) return;
			setState(() {
				_loadError = 'Failed to load profile.';
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
		if (formState == null || _user == null) return;

		if (!formState.saveAndValidate()) {
			return;
		}

		final values = formState.value;
		final instagramAccountRaw = values['instagramAccount'] as String?;
		final instagramAccount = instagramAccountRaw == null || instagramAccountRaw.trim().isEmpty
				? null
				: instagramAccountRaw;
		final request = UserUpdateRequest(
			values['firstName'],
			values['lastName'],
			values['username'],
			values['email'],
			values['phoneNumber'],
			instagramAccount,
			values['birthDate'],
			values['cityId'],
		);

		setState(() {
			_isLoading = true;
		});

		try {
			final updated = await _userProvider.update(_user!.id, request.toJson());
			if (!mounted) return;
			if (updated != null) {
				setState(() {
					_user = updated;
				});
			}
			await _showMessage(
				title: 'Saved',
				message: 'Your profile has been updated.',
			);
		} on Exception catch (e) {
			if (!mounted) return;
			var message = e.toString();
			if (message.contains('Exception:')) {
				message = message.replaceAll('Exception:', '').trim();
			}
			await _showMessage(title: 'Update Failed', message: message);
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

	Future<void> _showChangePasswordInfo() async {
		await _showMessage(
			title: 'Change Password',
			message: 'This feature is coming soon.',
		);
	}

	Future<bool> _confirmLogout() async {
		final shouldLogout = await showDialog<bool>(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Log out'),
				content: const Text('Are you sure you want to log out?'),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context, false),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () => Navigator.pop(context, true),
						child: const Text('Log out'),
					),
				],
			),
		);
		return shouldLogout ?? false;
	}

	String? _optionalPhoneValidator(String? value) {
		if (value == null || value.trim().isEmpty) {
			return null;
		}
		return FormBuilderValidators.phoneNumber()(value);
	}

	String _initials(User? user) {
		final first = user?.firstName.trim();
		final last = user?.lastName.trim();
		final firstInitial = first != null && first.isNotEmpty ? first[0] : '';
		final lastInitial = last != null && last.isNotEmpty ? last[0] : '';
		final initials = '$firstInitial$lastInitial'.toUpperCase();
		return initials.isEmpty ? 'U' : initials;
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final isLookupReady = !_isLoadingLookups && _loadError == null;
		final user = _user;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Profile'),
				automaticallyImplyLeading: widget.showBackButton,
				leading: widget.showBackButton
						? IconButton(
							icon: const Icon(Icons.arrow_back_ios_new),
							onPressed: () => Navigator.pop(context),
						)
						: null,
				actions: [
					IconButton(
						tooltip: 'Change Password',
						icon: const Icon(Icons.lock_outline),
						onPressed: _showChangePasswordInfo,
					),
					IconButton(
						tooltip: 'Logout',
						icon: const Icon(Icons.logout),
						onPressed: () async {
							final shouldLogout = await _confirmLogout();
							if (!shouldLogout) return;
							await context.read<AuthProvider>().logout();
						},
					),
				],
			),
			body: SafeArea(
				child: Stack(
					children: [
						Container(
							height: 220,
							decoration: const BoxDecoration(
								gradient: LinearGradient(
									colors: [Color(0xFF00C875), Color(0xFF5CE0B3)],
									begin: Alignment.topLeft,
									end: Alignment.bottomRight,
								),
							),
						),
						SingleChildScrollView(
							controller: widget.scrollController,
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									const SizedBox(height: 10),
									_buildHeader(theme, user),
									const SizedBox(height: 18),
									if (_isLoadingLookups)
										const Center(
											child: Padding(
												padding: EdgeInsets.only(top: 20),
												child: CircularProgressIndicator(strokeWidth: 2),
											),
										),
									if (_loadError != null)
										_buildError(theme),
									if (!_isLoadingLookups && _loadError == null)
										_buildForm(theme, user, isLookupReady),
								],
							),
						),
					],
				),
			),
		);
	}

	Widget _buildHeader(ThemeData theme, User? user) {
		final fullName = user == null
				? 'Your Profile'
				: '${user.firstName} ${user.lastName}'.trim();
		final subtitle = user?.username ?? 'Update your details';

		return Card(
			elevation: 0,
			margin: EdgeInsets.zero,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
				child: Row(
					children: [
						CircleAvatar(
							radius: 30,
							backgroundColor: const Color(0xFFECFFF6),
							child: Text(
								_initials(user),
								style: theme.textTheme.titleMedium?.copyWith(
									fontSize: 20,
									fontWeight: FontWeight.w700,
									color: const Color(0xFF00A565),
								),
							),
						),
						const SizedBox(width: 16),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										fullName.isEmpty ? 'Your Profile' : fullName,
										style: theme.textTheme.titleMedium?.copyWith(
											fontSize: 18,
											fontWeight: FontWeight.w700,
										),
									),
									const SizedBox(height: 4),
									Text(
										subtitle,
										style: theme.textTheme.bodyMedium?.copyWith(
											color: Colors.grey.shade600,
										),
									),
								],
							),
						),
					],
				),
			),
		);
	}

	Widget _buildError(ThemeData theme) {
		return Card(
			margin: const EdgeInsets.only(top: 16),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						Text(
							_loadError ?? 'Failed to load profile.',
							style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
							textAlign: TextAlign.center,
						),
						const SizedBox(height: 12),
						TextButton(
							onPressed: _isLoadingLookups ? null : _loadProfile,
							child: const Text('Retry'),
						),
					],
				),
			),
		);
	}

	Widget _buildForm(ThemeData theme, User? user, bool isLookupReady) {
		return Card(
			margin: const EdgeInsets.only(top: 6),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
				child: FormBuilder(
					key: _formKey,
					initialValue: {
						'firstName': user?.firstName ?? '',
						'lastName': user?.lastName ?? '',
						'username': user?.username ?? '',
						'email': user?.email ?? '',
						'phoneNumber': user?.phoneNumber ?? '',
						'instagramAccount': user?.instagramAccount ?? '',
						'birthDate': user?.birthDate,
						'cityId': user?.cityId,
					},
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							Text(
								'Account details',
								style: theme.textTheme.titleMedium?.copyWith(
									fontWeight: FontWeight.w700,
								),
							),
							const SizedBox(height: 16),
							FormBuilderTextField(
								name: 'firstName',
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.person_outline, size: 22),
									hintText: 'First Name',
								),
								validator: FormBuilderValidators.compose([
									FormBuilderValidators.required(),
									FormBuilderValidators.minLength(2),
									FormBuilderValidators.maxLength(50),
								]),
							),
							const SizedBox(height: 12),
							FormBuilderTextField(
								name: 'lastName',
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.person_outline, size: 22),
									hintText: 'Last Name',
								),
								validator: FormBuilderValidators.compose([
									FormBuilderValidators.required(),
									FormBuilderValidators.minLength(2),
									FormBuilderValidators.maxLength(50),
								]),
							),
							const SizedBox(height: 12),
							FormBuilderTextField(
								name: 'username',
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.person_outline, size: 22),
									hintText: 'Username',
								),
								validator: FormBuilderValidators.compose([
									FormBuilderValidators.required(),
									FormBuilderValidators.minLength(3),
									FormBuilderValidators.maxLength(30),
								]),
							),
							const SizedBox(height: 12),
							FormBuilderTextField(
								name: 'email',
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.email_outlined, size: 22),
									hintText: 'Email',
								),
								keyboardType: TextInputType.emailAddress,
								validator: FormBuilderValidators.compose([
									FormBuilderValidators.required(),
									FormBuilderValidators.email(),
								]),
							),
							const SizedBox(height: 12),
							FormBuilderTextField(
								name: 'phoneNumber',
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.phone_outlined, size: 22),
									hintText: 'Contact Number',
								),
								keyboardType: TextInputType.phone,
								validator: _optionalPhoneValidator,
							),
							const SizedBox(height: 12),
							FormBuilderTextField(
								name: 'instagramAccount',
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.alternate_email, size: 22),
									hintText: 'Instagram (optional)',
								),
							),
							const SizedBox(height: 12),
							FormBuilderDateTimePicker(
								name: 'birthDate',
								inputType: InputType.date,
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.cake_outlined, size: 22),
									hintText: 'Birth Date',
								),
								validator: FormBuilderValidators.required(),
							),
							const SizedBox(height: 12),
							FormBuilderDropdown<int>(
								name: 'cityId',
								enabled: isLookupReady,
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.location_city_outlined, size: 22),
									hintText: 'City',
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
							const SizedBox(height: 18),
							SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: _isLoading ? null : _submit,
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
											: const Text('Save Changes'),
								),
							),
						],
					),
				),
			),
		);
	}
}
