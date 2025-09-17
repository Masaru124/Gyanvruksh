import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/screens/navigation.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/widgets/forms/floating_form_field.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

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
            if (loggedIn['success'] == true) {
              final me = await ApiService().me();
              if (!mounted) return;
              if (me != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => NavigationScreen(user: me),
                  ),
                );
              }
            } else {
              setState(() { error = loggedIn['error'] ?? "Login failed after registration"; });
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Enhanced Particle Background
          ParticleBackground(
            particleCount: 25,
            maxParticleSize: 3.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 8,
            maxElementSize: 50,
            icons: const [
              Icons.person_add,
              Icons.school,
              Icons.email,
              Icons.lock,
              Icons.phone,
              Icons.location_on,
              Icons.star,
              Icons.verified_user,
            ],
          ),

          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonBlue.withOpacity(0.05),
            height: MediaQuery.of(context).size.height,
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Header Section
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MicroInteractionWrapper(
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back,
                                color: colorScheme.onSurface,
                                size: 28,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.surface.withOpacity(0.8),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        AnimatedTextWidget(
                          text: 'Create Account',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: FuturisticColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          animationType: AnimationType.fade,
                          duration: const Duration(milliseconds: 800),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        AnimatedTextWidget(
                          text: 'Registering as ${widget.subRole[0].toUpperCase() + widget.subRole.substring(1)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                          animationType: AnimationType.fade,
                          duration: const Duration(milliseconds: 1000),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0, duration: 500.ms),

                  const SizedBox(height: 20),

                  // Registration Form Card
                  GlassmorphismCard(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(24),
                    blurStrength: 15,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildSectionHeader('Basic Information', Icons.person, theme, colorScheme),

                        const SizedBox(height: 20),

                        // Full Name
                        FloatingFormField(
                          controller: nameCtrl,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Age
                        FloatingFormField(
                          controller: ageCtrl,
                          label: 'Age',
                          hint: 'Enter your age',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideX(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Gender Dropdown
                        _buildDropdownField(
                          value: selectedGender,
                          label: 'Gender',
                          items: genderOptions,
                          icon: Icons.people,
                          onChanged: (value) => setState(() => selectedGender = value),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 24),

                        // Contact Information Section
                        _buildSectionHeader('Contact Information', Icons.contact_phone, theme, colorScheme),

                        const SizedBox(height: 20),

                        // Email
                        FloatingFormField(
                          controller: emailCtrl,
                          label: 'Email Address',
                          hint: 'Enter your email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms)
                        .slideX(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Password
                        FloatingFormField(
                          controller: passCtrl,
                          label: 'Password',
                          hint: 'Create a password',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 600.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Phone Number
                        FloatingFormField(
                          controller: phoneNumberCtrl,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 700.ms)
                        .slideX(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 24),

                        // Address Section
                        _buildSectionHeader('Address & Emergency', Icons.location_on, theme, colorScheme),

                        const SizedBox(height: 20),

                        // Address
                        FloatingFormField(
                          controller: addressCtrl,
                          label: 'Address',
                          hint: 'Enter your address',
                          icon: Icons.home,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 800.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Emergency Contact
                        FloatingFormField(
                          controller: emergencyContactCtrl,
                          label: 'Emergency Contact',
                          hint: 'Emergency contact number',
                          icon: Icons.emergency,
                          keyboardType: TextInputType.phone,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 900.ms)
                        .slideX(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Account Details
                        FloatingFormField(
                          controller: accountDetailsCtrl,
                          label: 'Account Details',
                          hint: 'Bank account details',
                          icon: Icons.account_balance,
                          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1000.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms),

                        // Role-specific fields
                        if (widget.subRole == 'teacher' || widget.subRole == 'student') ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Personal Details', Icons.info, theme, colorScheme),
                          const SizedBox(height: 20),

                          // Date of Birth
                          _buildDatePickerField(theme, colorScheme)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1100.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Aadhar Card
                          FloatingFormField(
                            controller: aadharCardCtrl,
                            label: 'Aadhar Card Number',
                            hint: 'Enter Aadhar card number',
                            icon: Icons.credit_card,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1200.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),
                        ],

                        if (widget.subRole == 'teacher') ...[
                          const SizedBox(height: 16),

                          // Educational Qualification
                          FloatingFormField(
                            controller: educationalQualificationCtrl,
                            label: 'Educational Qualification',
                            hint: 'Enter your qualification',
                            icon: Icons.school,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1300.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Marital Status
                          _buildDropdownField(
                            value: selectedMaritalStatus,
                            label: 'Marital Status',
                            items: maritalStatusOptions,
                            icon: Icons.family_restroom,
                            onChanged: (value) => setState(() => selectedMaritalStatus = value),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1400.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Years of Experience
                          FloatingFormField(
                            controller: yearOfExperienceCtrl,
                            label: 'Years of Experience',
                            hint: 'Enter years of experience',
                            icon: Icons.work,
                            keyboardType: TextInputType.number,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1500.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),
                        ],

                        if (widget.subRole == 'student') ...[
                          const SizedBox(height: 16),

                          // Preferred Language
                          _buildDropdownField(
                            value: selectedLanguage,
                            label: 'Preferred Language',
                            items: languageOptions,
                            icon: Icons.language,
                            onChanged: (value) => setState(() => selectedLanguage = value),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1300.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Parents Contact
                          FloatingFormField(
                            controller: parentsContactDetailsCtrl,
                            label: 'Parents Contact',
                            hint: 'Enter parents contact number',
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1400.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Parents Email
                          FloatingFormField(
                            controller: parentsEmailCtrl,
                            label: 'Parents Email',
                            hint: 'Enter parents email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1500.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),
                        ],

                        if (widget.subRole == 'seller') ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Business Information', Icons.business, theme, colorScheme),
                          const SizedBox(height: 20),

                          // Seller Type
                          _buildDropdownField(
                            value: selectedSellerType,
                            label: 'Seller Type',
                            items: sellerTypeOptions,
                            icon: Icons.business_center,
                            onChanged: (value) => setState(() => selectedSellerType = value),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1100.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Aadhar Card
                          FloatingFormField(
                            controller: aadharCardCtrl,
                            label: 'Aadhar Card Number',
                            hint: 'Enter Aadhar card number',
                            icon: Icons.credit_card,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1200.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Company ID
                          FloatingFormField(
                            controller: companyIdCtrl,
                            label: 'Company ID',
                            hint: 'Enter company ID',
                            icon: Icons.business,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1300.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Seller Record
                          FloatingFormField(
                            controller: sellerRecordCtrl,
                            label: 'Seller Record',
                            hint: 'Enter seller record',
                            icon: Icons.history,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1400.ms)
                          .slideX(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Company Details
                          FloatingFormField(
                            controller: companyDetailsCtrl,
                            label: 'Company Details',
                            hint: 'Enter company details',
                            icon: Icons.info,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1500.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 16),

                          // Years of Experience
                          FloatingFormField(
                            controller: yearOfExperienceCtrl,
                            label: 'Years of Experience',
                            hint: 'Enter years of experience',
                            icon: Icons.work,
                            keyboardType: TextInputType.number,
                            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 1600.ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms),
                        ],

                        const SizedBox(height: 32),

                        // Error Message
                        if (error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .shake(duration: 500.ms),

                        const SizedBox(height: 24),

                        // Register Button
                        CustomAnimatedButton(
                          onPressed: loading ? () {} : _register,
                          text: loading ? 'Creating Account...' : 'Create Account',
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                          height: 56,
                          isLoading: loading,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1700.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Already have account
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Already have an account? Sign In',
                              style: TextStyle(
                                color: FuturisticColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1800.ms),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        NeumorphismContainer(
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        color: Colors.white.withOpacity(0.1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          border: InputBorder.none,
          icon: Icon(icon, color: FuturisticColors.primary),
        ),
        dropdownColor: Colors.black.withOpacity(0.8),
        style: const TextStyle(color: Colors.white),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item[0].toUpperCase() + item.substring(1)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePickerField(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          color: Colors.white.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: FuturisticColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDob != null
                    ? selectedDob!.toLocal().toString().split(' ')[0]
                    : 'Select Date of Birth',
                style: TextStyle(
                  color: selectedDob != null
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
