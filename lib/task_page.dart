import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskPage extends StatefulWidget {
  final String token;

  const TaskPage({super.key, required this.token});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List tasks = [];

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future<void> getTasks() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/tasks"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    final data = jsonDecode(response.body);

    setState(() {
      tasks = data['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      body: tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(tasks[index]['title']),
                    subtitle: Text(tasks[index]['status']),
                  ),
                );
              },
            ),
    );
  }
}
