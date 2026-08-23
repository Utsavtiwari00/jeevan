import 'package:jeevan/domain/repositories/auth_repository.dart';
import 'package:jeevan/domain/models/app_user.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(MockLatency.short);
    return _currentUser;
  }

  @override
  Future<AppUser> login(String email, String password) async {
    await Future.delayed(MockLatency.long);
    _currentUser = MockSeedData.user;
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmName,
    required String location,
  }) async {
    await Future.delayed(MockLatency.long);
    final user = AppUser(
      id: 'user-new',
      name: name,
      email: email,
      phone: phone,
      farmName: farmName,
      location: location,
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(MockLatency.medium);
    return otp == '123456';
  }

  @override
  
  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(MockLatency.short);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(MockLatency.short);
    _currentUser = null;
  }
}
