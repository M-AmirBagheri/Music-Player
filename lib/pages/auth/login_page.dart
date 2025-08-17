import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup_page.dart';
import '../shop/music_shop_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  late Socket _socket;

  @override
  void initState() {
    super.initState();
    _connectToServer(); // Connect to the server when the page is loaded
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

        // Handle login response from server
        if (response.startsWith('LOGIN_SUCCESS')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MusicShopPage()),
          );
        } else if (response.startsWith('ERROR')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $response')),
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

  void _handleLogin() {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Send login request to server
    String loginMessage = 'LOGIN;$email;$password';
    _socket.write(loginMessage);

    // You could also listen for responses from the server, but it's already handled in the listener.
  }

  @override
  void dispose() {
    _socket.close(); // Close the socket connection when leaving the page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Login", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email or Username",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text("Login"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
