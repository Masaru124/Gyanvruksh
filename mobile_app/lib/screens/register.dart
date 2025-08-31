import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';
import 'package:educonnect/screens/dashboard.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  final String subRole;

  const RegisterScreen({super.key, required this.role, required this.subRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final educationalQualificationCtrl = TextEditingController();
  String? selectedGender;
  String? selectedLanguage;
  bool loading = false;
  String? error;

  List<String> get genderOptions => ['Male', 'Female', 'Other'];
  List<String> get languageOptions => ['kannada', 'english', 'hindi'];

  void _register() async {
    setState(() { loading = true; error = null; });

    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty ||
        ageCtrl.text.isEmpty || selectedGender == null) {
      setState(() { error = "Please fill all required fields"; });
      setState(() { loading = false; });
      return;
    }

    if (widget.subRole == 'teacher' && educationalQualificationCtrl.text.isEmpty) {
      setState(() { error = "Educational qualification is required for teachers"; });
      setState(() { loading = false; });
      return;
    }

    if (widget.subRole == 'student' && selectedLanguage == null) {
      setState(() { error = "Preferred language is required for students"; });
      setState(() { loading = false; });
      return;
    }

    try {
      final ok = await ApiService().register(
        email: emailCtrl.text,
        password: passCtrl.text,
        fullName: nameCtrl.text,
        age: int.parse(ageCtrl.text),
        gender: selectedGender!.toLowerCase(),
        role: widget.role,
        subRole: widget.subRole,
        educationalQualification: widget.subRole == 'teacher' ? educationalQualificationCtrl.text : null,
        preferredLanguage: widget.subRole == 'student' ? selectedLanguage : null,
        isTeacher: widget.subRole == 'teacher',
      );
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
            Text(
              'Registering as ${widget.subRole[0].toUpperCase() + widget.subRole.substring(1)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ageCtrl,
              decoration: const InputDecoration(labelText: 'Age *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(labelText: 'Gender *'),
              items: genderOptions.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => selectedGender = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password *'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (widget.subRole == 'teacher') ...[
              TextField(
                controller: educationalQualificationCtrl,
                decoration: const InputDecoration(labelText: 'Educational Qualification *'),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.subRole == 'student') ...[
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: const InputDecoration(labelText: 'Preferred Language *'),
                items: languageOptions.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang[0].toUpperCase() + lang.substring(1)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedLanguage = value),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: loading ? null : _register,
              child: loading ? const CircularProgressIndicator() : const Text('Sign up'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Already have an account? Login'),
            )
          ],
        ),
      ),
    );
  }
}
