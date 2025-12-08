import 'package:shared_preferences/shared_preferences.dart';

class DeepLinkHandler {
  static const String _invitationCodeKey = 'pending_invitation_code';

  /// Extract invitation code from URI
  static Future<String?> extractInvitationCode(Uri uri) async {
    print('Extracting code from URI: ${uri.toString()}');
    
    // Handle custom scheme: coachapp://invite/{code}
    if (uri.scheme == 'coachapp' && uri.host == 'invite') {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    // Handle universal link: https://coachapp.com/invite/{code}
    if (uri.host == 'coachapp.com' || uri.host.contains('coachapp.com')) {
      if (uri.pathSegments.contains('invite')) {
        final index = uri.pathSegments.indexOf('invite');
        if (index < uri.pathSegments.length - 1) {
          return uri.pathSegments[index + 1];
        }
      }
      // Also handle: https://coachapp.com/invite/CODE
      if (uri.path.startsWith('/invite/')) {
        final segments = uri.pathSegments;
        if (segments.length >= 2 && segments[0] == 'invite') {
          return segments[1];
        }
      }
    }

    // Handle query parameter: ?code=ABC123
    if (uri.queryParameters.containsKey('code')) {
      return uri.queryParameters['code'];
    }

    return null;
  }

  /// Store invitation code for later use
  static Future<void> storeInvitationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_invitationCodeKey, code);
    print('Stored invitation code: $code');
  }

  /// Get pending invitation code
  static Future<String?> getPendingInvitationCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_invitationCodeKey);
    if (code != null) {
      print('Retrieved pending invitation code: $code');
    }
    return code;
  }

  /// Clear stored invitation code
  static Future<void> clearInvitationCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_invitationCodeKey);
    print('Cleared invitation code');
  }
}

