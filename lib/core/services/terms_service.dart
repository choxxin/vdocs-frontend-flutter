import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage Terms and Conditions acceptance
class TermsService {
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _termsVersionKey = 'terms_version';
  static const String _termsAcceptedDateKey = 'terms_accepted_date';
  
  // Update this version when T&C changes
  static const String currentTermsVersion = '1.0.0';

  /// Check if user has accepted the current version of T&C
  static Future<bool> hasAcceptedTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accepted = prefs.getBool(_termsAcceptedKey) ?? false;
      final version = prefs.getString(_termsVersionKey) ?? '';
      
      // User must have accepted AND it must be the current version
      return accepted && version == currentTermsVersion;
    } catch (e) {
      print('Error checking terms acceptance: $e');
      return false;
    }
  }

  /// Save T&C acceptance
  static Future<bool> acceptTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_termsAcceptedKey, true);
      await prefs.setString(_termsVersionKey, currentTermsVersion);
      await prefs.setString(
        _termsAcceptedDateKey,
        DateTime.now().toIso8601String(),
      );
      return true;
    } catch (e) {
      print('Error accepting terms: $e');
      return false;
    }
  }

  /// Clear T&C acceptance (for testing or logout)
  static Future<bool> clearTermsAcceptance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_termsAcceptedKey);
      await prefs.remove(_termsVersionKey);
      await prefs.remove(_termsAcceptedDateKey);
      return true;
    } catch (e) {
      print('Error clearing terms acceptance: $e');
      return false;
    }
  }

  /// Get the date when terms were accepted
  static Future<DateTime?> getAcceptanceDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_termsAcceptedDateKey);
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      return null;
    } catch (e) {
      print('Error getting acceptance date: $e');
      return null;
    }
  }
}
