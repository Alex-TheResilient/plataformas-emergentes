import '../models/user_model.dart';

class LoginViewModel {
  String email = '';
  String password = '';

  bool validateCredentials() {
    return email.isNotEmpty && password.isNotEmpty;
  }

  User getUser() {
    return User(email: email, password: password);
  }
}
