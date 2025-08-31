import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';
import 'package:educonnect/screens/role_selection.dart';
import 'package:educonnect/screens/dashboard.dart';
import 'package:educonnect/screens/admin_dashboard.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('EduConnect Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: loading ? null : _login, child: loading ? const CircularProgressIndicator() : const Text('Login')),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoleSelectionScreen())), child: const Text('Create account'))
          ],
        ),
      ),
    );
  }
}
