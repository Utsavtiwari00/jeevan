import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/app_user.dart';
import 'package:jeevan/domain/repositories/auth_repository.dart';
import 'package:jeevan/data/mock/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(email, password);
      ref.invalidate(currentUserProvider);
    });
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmName,
    required String location,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(
        name: name,
        phone: phone,
        email: email,
        password: password,
        farmName: farmName,
        location: location,
      );
    });
  }

  Future<void> verifyOtp(String otp) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyOtp(otp);
      ref.invalidate(currentUserProvider);
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPasswordReset(email);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      ref.invalidate(currentUserProvider);
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
