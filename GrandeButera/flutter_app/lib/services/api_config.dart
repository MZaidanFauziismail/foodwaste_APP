class ApiConfig {
  // Android emulator: 10.0.2.2 | Physical device: replace with your computer LAN IP.
  // Build example:
  // flutter build apk --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static String get serverBaseUrl {
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }
    return apiBaseUrl;
  }
}
