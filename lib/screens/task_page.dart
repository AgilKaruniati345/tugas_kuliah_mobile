import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../main.dart';

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

  // ================= FORMAT DEADLINE =================
  String formatDeadline(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    final dt = DateTime.tryParse(iso);
    if (dt == null) return "-";

    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  // ================= GET TASK =================
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

  // ================= ADD TASK =================
  Future<void> addTask(
    String title,
    String description,
    String? deadline,
  ) async {
    await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: {"title": title, "description": description, "deadline": deadline},
    );

    getTasks();
  }

  // ================= EDIT TASK =================
  Future<void> editTask(
    int id,
    String title,
    String description,
    String? deadline,
  ) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: {"title": title, "description": description, "deadline": deadline},
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

  // ================= LOGOUT =================
  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin mau keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
            },
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= ADD DIALOG =================
  void showAddDialog() {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final formKey = GlobalKey<FormState>();

    DateTime? selectedDateTime;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Tambah Task"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleC,
                    decoration: const InputDecoration(labelText: "Judul"),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Wajib diisi" : null,
                  ),
                  TextFormField(
                    controller: descC,
                    decoration: const InputDecoration(labelText: "Deskripsi"),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (date == null) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time == null) return;

                      setStateDialog(() {
                        selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                    child: const Text("Pilih Tanggal & Jam"),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    selectedDateTime == null
                        ? "Belum dipilih"
                        : formatDeadline(selectedDateTime!.toIso8601String()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  await addTask(
                    titleC.text,
                    descC.text,
                    selectedDateTime?.toIso8601String(),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= EDIT DIALOG =================
  void showEditDialog(Task task) {
    final titleC = TextEditingController(text: task.title);
    final descC = TextEditingController(text: task.description);
    final formKey = GlobalKey<FormState>();

    DateTime? selectedDateTime = task.deadline != null
        ? DateTime.tryParse(task.deadline!)
        : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Task"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: titleC),
                  TextFormField(controller: descC),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (date == null) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time == null) return;

                      setStateDialog(() {
                        selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                    child: const Text("Ubah Tanggal & Jam"),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    selectedDateTime == null
                        ? "-"
                        : formatDeadline(selectedDateTime!.toIso8601String()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  await editTask(
                    task.id,
                    titleC.text,
                    descC.text,
                    (selectedDateTime ??
                            DateTime.parse(
                              task.deadline ?? DateTime.now().toIso8601String(),
                            ))
                        .toIso8601String(),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= UI =================
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Task?"),
        content: const Text("Data akan dihapus permanen."),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),

          TextButton(
            onPressed: () async {
              await deleteTask(id);

              if (!mounted) return;

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
                final task = tasks[i];

                return Card(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        Text("Deadline: ${formatDeadline(task.deadline)}"),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(task.title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Deskripsi: ${task.description}"),
                              Text(
                                "Deadline: ${formatDeadline(task.deadline)}",
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => confirmDelete(task.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
