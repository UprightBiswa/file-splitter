class AppUrls {
  // Base API URL
  static const String baseUrl = "http://localhost:8080";

  // Endpoints
  static const String uploadFile = "/upload"; // POST
  static const String splitFile = "/split";   // POST - call Go to split
  static const String fetchSplits = "/splits"; // GET - fetch list of downloadable file parts
}
