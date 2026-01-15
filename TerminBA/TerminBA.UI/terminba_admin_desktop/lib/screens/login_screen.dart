import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true; // Hidden by default
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AuthProvider authProvider;

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = context.read<AuthProvider>();
  }

  void _login () async{
    String username = _usernameController.text;
    String password = _passwordController.text;


    try {
      await authProvider.login(username, password);
      // Handle successful login (e.g., navigate to another screen)
    } catch (e) {
      // Handle login error (e.g., show error message)
      print('Login error: $e');
    }
    // Implement login logic here
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: _buildLoginForm()
        ),
      );
    }

Widget _buildLoginForm() {
  // Use LayoutBuilder to get the parent's constraints (the screen size)
  return LayoutBuilder(
    builder: (context, constraints) {
      // Calculate a dynamic width: 70% of screen width, but never more than 500px
      double dynamicWidth = constraints.maxWidth * 0.7;
      if (dynamicWidth > 600) dynamicWidth = 600;
      if (dynamicWidth < 300) dynamicWidth = constraints.maxWidth * 0.9; // Narrow screens

      double dynamicHeight = constraints.maxHeight * 0.6; 
      if (dynamicHeight > 700) dynamicHeight = 700; // Cap the max height
      if (dynamicHeight < 560) dynamicHeight = 560; // Ensure it's tall enough for all fields

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SizedBox( 
            width: dynamicWidth,
            height: dynamicHeight,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey, width: 1.0),
                ),
              color: Color(0xF8F8F8F8),
              elevation: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 50),
                    
                    // Username
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.green,
                          ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(
                          Icons.key_outlined,
                          color: Colors.green,
                          ),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscured = !_isObscured),
                          color: Colors.green,
                        ),
                      ),
                    ),
                  const SizedBox(height: 150),
                    // Button that matches the dynamic width
                    SizedBox(
                      width: double.infinity, // Fills the dynamic container width
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                        ),
                        onPressed: () {
                          _login();
                        },
                        child: const Text("Login", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}