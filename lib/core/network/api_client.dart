class ApiClient {
  final String baseUrl;

  const ApiClient({this.baseUrl = 'https://api.example.com'});

  Future<void> healthCheck() async {
    // TODO: connecter au backend FastAPI.
  }
}
