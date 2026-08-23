import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmName,
    required String location,
  });
  Future<bool> verifyOtp(String otp);
  Future<void> sendPasswordReset(String email);
  Future<AppUser?> getCurrentUser();
  Future<void> logout();
}
