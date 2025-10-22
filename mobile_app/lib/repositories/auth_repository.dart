import '../services/enhanced_api_service.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      if (response.isSuccess) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'error': response.userMessage};
      }
    } catch (e) {
      return {'success': false, 'error': 'Login failed: ${e.toString()}'};
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String subRole,
    int? age,
    String? gender,
    String? educationalQualification,
    String? preferredLanguage,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? aadharCard,
    String? accountDetails,
    DateTime? dob,
    String? maritalStatus,
    int? yearOfExperience,
    String? parentsContactDetails,
    String? parentsEmail,
    String? sellerType,
    String? companyId,
    String? sellerRecord,
    String? companyDetails,
    bool isTeacher = false,
  }) async {
    try {
      final response = await ApiService.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        subRole: subRole,
        age: age,
        gender: gender,
        educationalQualification: educationalQualification,
        preferredLanguage: preferredLanguage,
        phoneNumber: phoneNumber,
        address: address,
        emergencyContact: emergencyContact,
        aadharCard: aadharCard,
        accountDetails: accountDetails,
        dob: dob,
        maritalStatus: maritalStatus,
        yearOfExperience: yearOfExperience,
        parentsContactDetails: parentsContactDetails,
        parentsEmail: parentsEmail,
        sellerType: sellerType,
        companyId: companyId,
        sellerRecord: sellerRecord,
        companyDetails: companyDetails,
        isTeacher: isTeacher,
      );
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final response = await ApiService.logout();
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiService.getProfile();
      return response.isSuccess ? response.data as Map<String, dynamic>? : null;
    } catch (e) {
      return null;
    }
  }
}
