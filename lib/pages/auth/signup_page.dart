import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../shop/music_shop_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late Socket _socket;

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  // Connect to the server using Socket
  Future<void> _connectToServer() async {
    try {
      _socket = await Socket.connect('localhost', 12345);
      print('Connected to server');

      // Listen for server responses
      _socket.listen((data) {
        String response = String.fromCharCodes(data);
        print('Received from server: $response');

        // Handle sign-up response from server
        if (response.startsWith('SIGNUP_SUCCESS')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MusicShopPage()),
          );
        } else if (response.startsWith('ERROR')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-up failed: $response')),
          );
        }
      });
    } catch (e) {
      print('Error connecting to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server')),
      );
    }
  }

  // Handle Sign-Up process
  void _signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signing up...')),
      );

      String username = _usernameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      _connectToServer(); // Establish connection to the server

      // Send sign-up request to server
      String signUpMessage = 'SIGNUP;$username;$email;$password';
      _socket.write(signUpMessage);
    }
  }

  @override
  void dispose() {
    _socket.close(); // Close the socket connection when leaving the page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8 ||
                      !RegExp(r'[A-Z]').hasMatch(value) ||
                      !RegExp(r'[a-z]').hasMatch(value) ||
                      !RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Password must contain uppercase, lowercase, number and be 8+ characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
