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
  final phoneNumberCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emergencyContactCtrl = TextEditingController();
  final aadharCardCtrl = TextEditingController();
  final accountDetailsCtrl = TextEditingController();
  final yearOfExperienceCtrl = TextEditingController();
  final parentsContactDetailsCtrl = TextEditingController();
  final parentsEmailCtrl = TextEditingController();
  final companyIdCtrl = TextEditingController();
  final sellerRecordCtrl = TextEditingController();
  final companyDetailsCtrl = TextEditingController();
  String? selectedGender;
  String? selectedLanguage;
  String? selectedMaritalStatus;
  String? selectedSellerType;
  DateTime? selectedDob;
  bool loading = false;
  String? error;

  List<String> get genderOptions => ['Male', 'Female', 'Other'];
  List<String> get languageOptions => ['kannada', 'english', 'hindi'];
  List<String> get maritalStatusOptions => ['Single', 'Married', 'Divorced', 'Widowed'];
  List<String> get sellerTypeOptions => ['common', 'business'];

  void _register() async {
    setState(() { loading = true; error = null; });

    // Basic required fields
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty ||
        selectedGender == null || phoneNumberCtrl.text.isEmpty || addressCtrl.text.isEmpty ||
        emergencyContactCtrl.text.isEmpty || accountDetailsCtrl.text.isEmpty) {
      setState(() { error = "Please fill all required fields"; });
      setState(() { loading = false; });
      return;
    }

    // Role-specific validations
    if (widget.subRole == 'teacher') {
      if (educationalQualificationCtrl.text.isEmpty || selectedMaritalStatus == null ||
          yearOfExperienceCtrl.text.isEmpty || selectedDob == null || aadharCardCtrl.text.isEmpty) {
        setState(() { error = "Please fill all teacher-specific fields"; });
        setState(() { loading = false; });
        return;
      }
    }

    if (widget.subRole == 'student') {
      if (selectedLanguage == null || selectedDob == null || aadharCardCtrl.text.isEmpty ||
          parentsContactDetailsCtrl.text.isEmpty || parentsEmailCtrl.text.isEmpty) {
        setState(() { error = "Please fill all student-specific fields"; });
        setState(() { loading = false; });
        return;
      }
    }

    if (widget.subRole == 'seller') {
      if (selectedSellerType == null || aadharCardCtrl.text.isEmpty || companyIdCtrl.text.isEmpty ||
          sellerRecordCtrl.text.isEmpty || companyDetailsCtrl.text.isEmpty || yearOfExperienceCtrl.text.isEmpty) {
        setState(() { error = "Please fill all seller-specific fields"; });
        setState(() { loading = false; });
        return;
      }
    }

    if (widget.subRole == 'buyer') {
      // No additional required fields for buyer
    }

    try {
      final ok = await ApiService().register(
        email: emailCtrl.text,
        password: passCtrl.text,
        fullName: nameCtrl.text,
        age: ageCtrl.text.isNotEmpty ? int.parse(ageCtrl.text) : null,
        gender: selectedGender!.toLowerCase(),
        role: widget.role,
        subRole: widget.subRole,
        educationalQualification: educationalQualificationCtrl.text.isNotEmpty ? educationalQualificationCtrl.text : null,
        preferredLanguage: selectedLanguage,
        phoneNumber: phoneNumberCtrl.text,
        address: addressCtrl.text,
        emergencyContact: emergencyContactCtrl.text,
        aadharCard: aadharCardCtrl.text,
        accountDetails: accountDetailsCtrl.text,
        dob: selectedDob,
        maritalStatus: selectedMaritalStatus,
        yearOfExperience: yearOfExperienceCtrl.text.isNotEmpty ? int.parse(yearOfExperienceCtrl.text) : null,
        parentsContactDetails: parentsContactDetailsCtrl.text,
        parentsEmail: parentsEmailCtrl.text,
        sellerType: selectedSellerType,
        companyId: companyIdCtrl.text,
        sellerRecord: sellerRecordCtrl.text,
        companyDetails: companyDetailsCtrl.text,
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
              decoration: const InputDecoration(labelText: 'Age'),
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
            const SizedBox(height: 8),
            TextField(
              controller: phoneNumberCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number *'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Address *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emergencyContactCtrl,
              decoration: const InputDecoration(labelText: 'Emergency Contact *'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: accountDetailsCtrl,
              decoration: const InputDecoration(labelText: 'Account Details *'),
            ),
            const SizedBox(height: 12),
            if (widget.subRole == 'teacher' || widget.subRole == 'student') ...[
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDob = picked);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth *',
                      hintText: selectedDob != null ? selectedDob!.toLocal().toString().split(' ')[0] : 'Select DOB',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.subRole == 'teacher') ...[
              TextField(
                controller: educationalQualificationCtrl,
                decoration: const InputDecoration(labelText: 'Educational Qualification *'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedMaritalStatus,
                decoration: const InputDecoration(labelText: 'Marital Status *'),
                items: maritalStatusOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) => setState(() => selectedMaritalStatus = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: yearOfExperienceCtrl,
                decoration: const InputDecoration(labelText: 'Year of Experience *'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aadharCardCtrl,
                decoration: const InputDecoration(labelText: 'Aadhar Card *'),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.subRole == 'student') ...[
              TextField(
                controller: aadharCardCtrl,
                decoration: const InputDecoration(labelText: 'Aadhar Card *'),
              ),
              const SizedBox(height: 8),
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
              TextField(
                controller: parentsContactDetailsCtrl,
                decoration: const InputDecoration(labelText: 'Parents Contact Details *'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: parentsEmailCtrl,
                decoration: const InputDecoration(labelText: 'Parents Email *'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
            ],
            if (widget.subRole == 'seller') ...[
              DropdownButtonFormField<String>(
                value: selectedSellerType,
                decoration: const InputDecoration(labelText: 'Seller Type *'),
                items: sellerTypeOptions.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type[0].toUpperCase() + type.substring(1)));
                }).toList(),
                onChanged: (value) => setState(() => selectedSellerType = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aadharCardCtrl,
                decoration: const InputDecoration(labelText: 'Aadhar Card *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: companyIdCtrl,
                decoration: const InputDecoration(labelText: 'Company ID *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sellerRecordCtrl,
                decoration: const InputDecoration(labelText: 'Seller Record *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: companyDetailsCtrl,
                decoration: const InputDecoration(labelText: 'Company Details *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: yearOfExperienceCtrl,
                decoration: const InputDecoration(labelText: 'Year of Experience *'),
                keyboardType: TextInputType.number,
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
