import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/api_error_handler.dart';
import '../providers/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to login state
    final loginState = ref.watch(loginProvider);
    final bool isLoggedIn = loginState.isLoggedIn;

    // If login state changes to logged in, the router will automatically
    // redirect to the home screen due to our router configuration

    // Show error message if there is one
    if (loginState.errorMessage != null) {
      // Use delayed microtask to avoid build phase errors
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(loginState.errorMessage!),
      //       backgroundColor: Colors.red,
      //       action: SnackBarAction(
      //         label: 'Dismiss',
      //         onPressed: () {
      //           // Clear the error
      //           ref.read(loginProvider.notifier).clearError();
      //         },
      //       ),
      //     ),
      //   );
      // });
      ApiErrorHandler.showErrorSnackBar(context, loginState.errorMessage!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLoggedIn) ...[
                Text("Welcome ${ loginState.isLoggedIn }"),
                ElevatedButton(
                  onPressed: loginState.isLoading
                      ? null
                      : _logout,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loginState.isLoading
                      ? CircularProgressIndicator()
                      : Text('Logout', style: TextStyle(fontSize: 16)),
                ),
              ]
              else ...[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  enabled: !loginState.isLoading,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  enabled: !loginState.isLoading,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: loginState.isLoading
                      ? null
                      : _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loginState.isLoading
                      ? CircularProgressIndicator()
                      : Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Trigger login
      await ref.read(loginProvider.notifier).login(
        _usernameController.text,
        _passwordController.text,
      );
    }
  }

  Future<void> _logout() async {
    await ref.read(loginProvider.notifier).logout();
  }
}