import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';
import 'package:educonnect/screens/role_selection.dart';
import 'package:educonnect/screens/navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  void _login() async {
    setState(() { loading = true; error = null; });
    try {
      final ok = await ApiService().login(emailCtrl.text, passCtrl.text);
      if (!mounted) return;
      if (ok) {
        final me = ApiService().me();
        if (me != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NavigationScreen(user: me)));
        }
      } else {
        setState(() { error = "Invalid credentials"; });
      }
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Icon(Icons.school, size: 80, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'EduConnect',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Empowering Education',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),
              // Email Field
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password feature coming soon!')),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              // Create Account
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
