import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TaskService {
  // Menggunakan IP lokal laptopmu hasil ipconfig
  static const String baseUrl = 'http://192.168.1.23:8000/api';

  // ================= 1. GET ALL TASKS =================
  static Future<List<dynamic>> getTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        // Menyesuaikan jika response API dibungkus dalam key 'data'
        if (decodedData.containsKey('data')) {
          return decodedData['data'] is List ? decodedData['data'] : [];
        }
        return [];
      } else {
        debugPrint(
            "Gagal getTasks. Status: ${response.statusCode}, Body: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Eror fatal pada TaskService.getTasks: $e");
      return [];
    }
  }

  // ================= 2. ADD NEW TASK =================
  static Future<bool> addTask(
      String title, String description, String? deadline, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'deadline': deadline,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Eror fatal pada TaskService.addTask: $e");
      return false;
    }
  }

  // ================= 3. UPDATE TASK =================
  static Future<bool> updateTask(int id, String title, String description,
      String deadline, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'deadline': deadline.isEmpty ? null : deadline,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Eror fatal pada TaskService.updateTask: $e");
      return false;
    }
  }

  // ================= 4. DELETE TASK =================
  static Future<bool> deleteTask(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Eror fatal pada TaskService.deleteTask: $e");
      return false;
    }
  }
}
