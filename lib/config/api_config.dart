class ApiConfig {
  // Change this to your actual machine's IP address
  // Use your computer's IP address on the same network as your testing device
  // For example: '192.168.1.5:3000'
  static const String baseUrl = '10.0.2.2:3000';

  // API endpoints
  static String get loginUrl => 'http://$baseUrl/api/v1/auth/login';
  static String get registerUrl => 'http://$baseUrl/api/v1/auth/register';
  static String get authMeUrl => 'http://$baseUrl/api/v1/auth/me';
  static String get authCheck => 'http://$baseUrl/api/v1/auth/check';
  static String getSaloonsByOwnerUrl(int ownerId) =>
      'http://$baseUrl/api/v1/saloons/owner/$ownerId';
  static String get createSaloonUrl => 'http://$baseUrl/api/v1/saloons';
  static String getSaloonUrl(int id) => 'http://$baseUrl/api/v1/saloons/$id';
  static String getUserUrl(int id) => 'http://$baseUrl/api/v1/users/$id';
  static String get saloonsListUrl => '/api/v1/saloons';
  static String get nearbySaloonListUrl =>
      'http://$baseUrl/api/v1/saloons/nearby';
  static String addServiceUrl(int saloonId) =>
      'http://$baseUrl/api/v1/saloons/$saloonId/services';
}
