import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashLocalPassword(String password) {
  final bytes = utf8.encode(password.trim());
  return sha256.convert(bytes).toString();
}

bool verifyLocalPassword(String password, String storedHash) {
  return hashLocalPassword(password) == storedHash;
}
