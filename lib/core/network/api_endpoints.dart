class ApiEndpoints {
  // Base modules
  static const String auth = '/auth';

  // AUTH
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh';

  // USERS
  static const String me = '$users/me';
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
}