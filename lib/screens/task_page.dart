import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/task_model.dart';

class TaskPage extends StatefulWidget {
  final String token;

  const TaskPage({super.key, required this.token});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  bool isLoading = true;

  final String baseUrl = "http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  // ================= GET =================
  Future<void> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tasks"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data is List) ? data : data['data'];

        setState(() {
          tasks = list.map<Task>((e) => Task.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= ADD =================
  Future<void> addTask(String title) async {
    await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: {"title": title},
    );

    getTasks();
  }

  // ================= EDIT =================
  Future<void> editTask(int id, String title) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: {"title": title},
    );

    getTasks();
  }

  // ================= DELETE =================
  Future<void> deleteTask(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    getTasks();
  }

  Future<void> logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logout berhasil")));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  // ================= CONFIRM DELETE (INI YANG KAMU MAU) =================
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Task?"),
        content: const Text("Data akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // BATAL
            },
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await deleteTask(id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil dihapus")),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= ADD DIALOG =================
  void showAddDialog() {
    final c = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Task"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: c,
            decoration: const InputDecoration(
              labelText: "Judul Task",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Judul task tidak boleh kosong";
              }
              if (value.trim().length < 3) {
                return "Minimal 3 karakter";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await addTask(c.text);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil ditambahkan")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= EDIT DIALOG =================
  void showEditDialog(Task task) {
    final c = TextEditingController(text: task.title);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: c,
            decoration: const InputDecoration(
              labelText: "Judul Task",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Judul task tidak boleh kosong";
              }
              if (value.trim().length < 3) {
                return "Minimal 3 karakter";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await editTask(task.id, c.text);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil diperbarui")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF6FF),

      appBar: AppBar(
        title: const Text("Task List"),
        centerTitle: true,
        backgroundColor: const Color(0xff90CAF9),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text("Belum ada data"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffBBDEFB),
                      child: Icon(Icons.task, color: Colors.blue),
                    ),
                    title: Text(tasks[i].title),
                    subtitle: Text("ID: ${tasks[i].id}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => showEditDialog(tasks[i]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(tasks[i].id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff90CAF9),
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
