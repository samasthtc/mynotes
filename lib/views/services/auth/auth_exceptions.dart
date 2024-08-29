// register exceptions
class EmailAlreadyInUseAuthException implements Exception {}
class WeakPasswordAuthException implements Exception {}

// login exceptions
class UserNotFoundAuthException implements Exception {}
class WrongPasswordAuthException implements Exception {}

// email verification exceptions
class InvalidEmailAuthException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}
class UserNotLoggedInAuthException implements Exception {}


