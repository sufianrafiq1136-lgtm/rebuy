import '../models/user_model.dart';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  
  User? _currentUser;
  final Map<String, String> _users = {
    'user@rebuy.pk': 'Password123',
  };

  factory MockAuthService() {
    return _instance;
  }

  MockAuthService._internal();

  User? get currentUser => _currentUser;

  Future<String?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_users.containsKey(email)) {
      return 'Email already registered';
    }

    _users[email] = password;
    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
      itemsListed: 0,
      itemsSold: 0,
      itemsBought: 0,
    );
    return null;
  }

  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!_users.containsKey(email)) {
      return 'Email not registered';
    }

    if (_users[email] != password) {
      return 'Incorrect password';
    }

    _currentUser = User(
      id: 'user_${email.hashCode}',
      name: email.split('@')[0],
      email: email,
      createdAt: DateTime.now(),
      itemsListed: 12,
      itemsSold: 5,
      itemsBought: 3,
    );
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<User?> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }
}
