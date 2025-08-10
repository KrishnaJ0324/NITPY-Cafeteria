
import 'package:http/http.dart' as http;
import 'dart:convert';


class BackendService {
  static const String baseUrl = 'http://192.168.245.119:5000'; // localhost for Android emulator

  Future<http.Response> login(String email, String password) {
  return http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": email, "password": password}),
  );
}


  Future<http.Response> getMeals() {
    return http.get(Uri.parse('$baseUrl/meals'));
  }

  Future<http.Response> getAnnouncements() {
    return http.get(Uri.parse('$baseUrl/announcements'));
  }

  // Placeholder for future implementation
  Future<http.Response> submitRating(String studentId, double rating) {
    final now = DateTime.now().toIso8601String();
    final body = '{"student_id": "$studentId", "rating": $rating, "date": "$now"}';
    return http.post(
      Uri.parse('$baseUrl/submit-rating'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }

  Future<http.Response> sendFeedback(String studentId, String message) {
    final now = DateTime.now().toIso8601String();
    final body = '{"student_id": "$studentId", "message": "$message", "date": "$now"}';
    return http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }
}