import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  String? selectedGender;
  String? selectedSubRole;
  bool loading = false;
  String? error;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> subRoleOptions = ['teacher', 'seller', 'buyer', 'student'];

  void _createAdmin() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty ||
        nameCtrl.text.isEmpty ||
        ageCtrl.text.isEmpty ||
        selectedGender == null ||
        selectedSubRole == null) {
      setState(() {
        error = "Please fill all required fields";
        loading = false;
      });
      return;
    }

    try {
      final ok = await ApiService().createAdmin(
        email: emailCtrl.text,
        password: passCtrl.text,
        fullName: nameCtrl.text,
        age: int.parse(ageCtrl.text),
        gender: selectedGender!.toLowerCase(),
        role: 'admin',
        subRole: selectedSubRole!,
      );
      if (ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin user created successfully')));
        Navigator.of(context).pop();
      } else {
        setState(() {
          error = "Failed to create admin user";
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Admin User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name *'),
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
            DropdownButtonFormField<String>(
              value: selectedSubRole,
              decoration: const InputDecoration(labelText: 'Sub Role *'),
              items: subRoleOptions.map((subRole) {
                return DropdownMenuItem(value: subRole, child: Text(subRole));
              }).toList(),
              onChanged: (value) => setState(() => selectedSubRole = value),
            ),
            const SizedBox(height: 12),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: loading ? null : _createAdmin,
              child: loading ? const CircularProgressIndicator() : const Text('Create Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
