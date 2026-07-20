// PH1-008 / PH1-024: the cached customer profile (PII) must live in secure
// storage, getUser() is an in-memory accessor, cold-start rehydration is
// token-gated, and clearSession purges the persisted blob.
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

const _user = UserModel(
  id: 'u-1',
  name: 'Test Customer',
  email: 'test@example.com',
  phone: '+966500000000',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await CacheClient.init();
    currentUser.value = null;
    repo = AuthRepository(_FakeAuthService());
  });

  test('saveUser writes to secure storage, not plaintext SharedPreferences',
      () async {
    await repo.saveUser(_user);

    expect(await SecureStorage.getSecuredString(kUserData), isNotNull);
    expect(CacheClient.getString(kUserData), isEmpty,
        reason: 'no plaintext SharedPreferences copy may remain');
  });

  test('getUser() reads only the in-memory cache (no disk hydration)',
      () async {
    await repo.saveUser(_user);
    expect(repo.getUser()!.id, 'u-1');

    // A fresh repository has an empty in-memory cache even if a blob exists.
    final fresh = AuthRepository(_FakeAuthService());
    expect(fresh.getUser(), isNull);
  });

  test('restoreCachedUser rehydrates when a valid access token is present',
      () async {
    await SecureStorage.saveSecuredString(kAccessToken, 'valid-token');
    await repo.saveUser(_user);

    final fresh = AuthRepository(_FakeAuthService());
    final restored = await fresh.restoreCachedUser();
    expect(restored, isNotNull);
    expect(restored!.email, 'test@example.com');
    expect(fresh.getUser()!.id, 'u-1');
  });

  test('PH1-024: restoreCachedUser returns null with no token even if a stale '
      'blob exists (residue/enumeration guard)', () async {
    await repo.saveUser(_user); // persists kUserData
    await SecureStorage.deleteSecuredString(kAccessToken); // no token

    final fresh = AuthRepository(_FakeAuthService());
    expect(await fresh.restoreCachedUser(), isNull);
  });

  test('PH1-024: clearSession purges the persisted user blob', () async {
    await SecureStorage.saveSecuredString(kAccessToken, 'valid-token');
    await repo.saveUser(_user);

    await repo.clearSession();

    expect(await SecureStorage.getSecuredString(kUserData), isNull);
    expect(repo.getUser(), isNull);
    // And it cannot be resurrected even if a token were re-added.
    await SecureStorage.saveSecuredString(kAccessToken, 'valid-token');
    expect(await repo.restoreCachedUser(), isNull);
  });
}
