import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    try {
      // === API DIMATIKAN SEMENTARA UNTUK TESTING UI ===
      /*
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/register"),
        headers: {"Accept": "application/json"},
        body: {
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      final data = jsonDecode(response.body);
      */
      // ===============================================

      // Langsung anggap server merespons sukses (200)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text("Register berhasil (Bypass)")));

      // Kembali ke halaman Login
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("REGISTER")),
          ],
        ),
      ),
    );
  }
}
