import 'package:flutter/material.dart';
import 'register.dart';

class SubRoleSelectionScreen extends StatefulWidget {
  final String selectedRole;
  const SubRoleSelectionScreen({super.key, required this.selectedRole});

  @override
  State<SubRoleSelectionScreen> createState() => _SubRoleSelectionScreenState();
}

class _SubRoleSelectionScreenState extends State<SubRoleSelectionScreen> {
  String? selectedSubRole;

  List<String> get options {
    if (widget.selectedRole == 'service_provider') {
      return ['teacher', 'seller'];
    } else if (widget.selectedRole == 'service_seeker') {
      return ['student', 'buyer'];
    } else {
      return [];
    }
  }

  void _onSubRoleSelected(String subRole) {
    setState(() {
      selectedSubRole = subRole;
    });
  }

  void _nextStep() {
    if (selectedSubRole != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegisterScreen(
            role: widget.selectedRole,
            subRole: selectedSubRole!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('No Sub-Roles')),
        body: const Center(child: Text('No sub-roles available for this role.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Sub-Role')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your sub-role',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...options.map((option) => _buildSubRoleOption(option)).toList(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: selectedSubRole != null ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubRoleOption(String subRole) {
    final isSelected = selectedSubRole == subRole;
    return InkWell(
      onTap: () => _onSubRoleSelected(subRole),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              subRole[0].toUpperCase() + subRole.substring(1),
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
