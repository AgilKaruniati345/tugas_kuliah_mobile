import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  Future<List> getTasks(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/tasks'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final result = json.decode(response.body);

    return result['data']; // WAJIB INI
  }
}
