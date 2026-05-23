import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/main.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/screens/sign_up_screen.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	bool _showPassword = false;
	bool _isLoading = false;
	final TextEditingController _usernameController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();

	@override
	void dispose() {
		_usernameController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _login() async {
		final username = _usernameController.text.trim();
		final password = _passwordController.text.trim();
		const int roleId = 1;

		if (username.isEmpty || password.isEmpty) {
			await _showMessage(
				title: 'Validation Error',
				message: 'Username and password cannot be empty.',
			);
			return;
		}

		setState(() {
			_isLoading = true;
		});

		try {
			final authProvider = context.read<AuthProvider>();
			await authProvider.login(username, password, roleId);

			if (!mounted) return;
			Navigator.pushReplacement(
				context,
				MaterialPageRoute(
					builder: (context) => const MyHomePage(title: 'TerminBA'),
				),
			);
		} on Exception catch (e) {
			if (!mounted) return;
			var message = e.toString();
			if (message.contains('Exception:')) {
				message = message.replaceAll('Exception:', '').trim();
			}
			await _showMessage(title: 'Login Failed', message: message);
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

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		return Scaffold(
			body: SafeArea(
				child: Center(
					child: Padding(
						padding: const EdgeInsets.symmetric(
							horizontal: 28,
              vertical: 28,
						),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
							Text(
								'Login',
								style: theme.textTheme.displayLarge?.copyWith(
									color: const Color(0xFF00C875),
									fontSize: 34,
									fontWeight: FontWeight.w800,
								),
							),
							const SizedBox(height: 12),
							Text(
								'Have Fun with Friends!',
								style: theme.textTheme.titleMedium?.copyWith(
									fontSize: 18,
									fontWeight: FontWeight.w600,
								),
							),
							const SizedBox(height: 36),
							TextField(
								controller: _usernameController,
								decoration: InputDecoration(
									prefixIcon: const Icon(Icons.person_outline, size: 22),
									hintText: 'Username',
									contentPadding: const EdgeInsets.symmetric(
										horizontal: 18,
										vertical: 18,
									),
								),
							),
							const SizedBox(height: 18),
							TextField(
								controller: _passwordController,
								obscureText: !_showPassword,
								decoration: InputDecoration(
									prefixIcon: const Icon(Icons.lock_outline, size: 22),
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
									hintText: 'Password',
									contentPadding: const EdgeInsets.symmetric(
										horizontal: 18,
										vertical: 18,
									),
								),
							),
							const SizedBox(height: 14),
							Align(
								alignment: Alignment.centerLeft,
								child: Text(
									'Forgot Password?',
									style: theme.textTheme.bodyMedium?.copyWith(
										color: const Color(0xFF00C875),
										fontSize: 15,
									),
								),
							),
							const SizedBox(height: 28),
							SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: _isLoading ? null : _login,
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
										: const Text('Login gasiranje'),
								),
							),
							const SizedBox(height: 20),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Text(
										"Don't have an account? ",
										style: theme.textTheme.bodyMedium?.copyWith(
											fontSize: 15,
										),
									),
									TextButton(
										onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SignUpScreen(),
                          ),
                        );
										},
										child: Text(
											'Sign Up',
											style: theme.textTheme.bodyMedium?.copyWith(
												color: const Color(0xFF00C875),
												fontWeight: FontWeight.w600,
												fontSize: 15,
										),
									),
              )],
							),
						]),
					),
			),
		));
	}
}
