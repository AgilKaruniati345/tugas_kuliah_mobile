import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/register_page.dart';
import 'screens/task_page.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: SplashScreen(token: token),
    );
  }
}

/// =======================
/// LOGIN PAGE
/// =======================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    // ===========================
    // BYPASS LOGIN (sementara)
    // ===========================
    String dummyToken = "bypass_token_12345";

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPage(token: dummyToken),
      ),
    );

    setState(() => isLoading = false);

    /*
    // ===========================
    // LOGIN ASLI (aktifkan kalau server sudah jalan)
    // ===========================
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.4:8001/api/login"),
        headers: {"Accept": "application/json"},
        body: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ?? data['access_token'];

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TaskPage(token: token),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server tidak terhubung")),
      );
    }

    setState(() => isLoading = false);
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.task_alt,
                        size: 60,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Task Management",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Login to continue",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Belum punya akun? Register",
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
