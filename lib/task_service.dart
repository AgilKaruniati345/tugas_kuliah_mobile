import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
 Future addTask(String title, String token) async {
  final response = await http.post(
    Uri.parse("http://10.0.2.2:8000/api/tasks"),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': title,
    }),
  );

  return response.body;
}
