/// Centralized strings — keeps copy consistent and makes future
/// localization (multi-language support) much easier to bolt on,
/// since every UI string already routes through one place.
class AppStrings {
  AppStrings._();

  static const String appName = 'ALU Bridge';
  static const String tagline = 'Connecting talent with opportunity';

  // Auth
  static const String login = 'Log In';
  static const String register = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String emailHint = 'Email address';
  static const String passwordHint = 'Password';
  static const String confirmPasswordHint = 'Confirm password';
  static const String chooseRole = 'How will you use ALU Bridge?';
  static const String roleStudent = 'I am a Student';
  static const String roleStartup = 'I am a Startup Founder';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String invalidEmail = 'Enter a valid email address.';
  static const String weakPassword = 'Password must be at least 6 characters.';
  static const String passwordMismatch = 'Passwords do not match.';
}
