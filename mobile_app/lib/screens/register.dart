import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';
import 'package:educonnect/screens/dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  bool isTeacher = false;
  bool loading = false;
  String? error;

  void _register() async {
    setState(() { loading = true; error = null; });
    try {
      final ok = await ApiService().register(emailCtrl.text, passCtrl.text, nameCtrl.text, isTeacher);
      if (ok) {
        final loggedIn = await ApiService().login(emailCtrl.text, passCtrl.text);
        if (!mounted) return;
        if (loggedIn) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
        }
      } else {
        setState(() { error = "Registration failed"; });
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
      appBar: AppBar(title: const Text('Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Register as teacher'),
                Switch(value: isTeacher, onChanged: (v) => setState(() => isTeacher = v)),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: loading ? null : _register, child: loading ? const CircularProgressIndicator() : const Text('Sign up')),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Already have an account? Login'))
          ],
        ),
      ),
    );
  }
}
