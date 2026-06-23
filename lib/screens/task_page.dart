import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../main.dart';
import '../services/task_service.dart';

class TaskPage extends StatefulWidget {
  final String token;

  const TaskPage({super.key, required this.token});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  bool isLoading = true;

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
      final list = await TaskService.getTasks(widget.token);

      if (!mounted) return;
      setState(() {
        // Pemetaan data yang bersih tanpa memicu warning tipe data
        tasks = list.map((e) => Task.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Eror saat mengambil data di UI: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ================= ADD TASK =================
  Future<bool> addTask(
      String title, String description, String? deadline) async {
    final success =
        await TaskService.addTask(title, description, deadline, widget.token);
    if (success) {
      getTasks();
      return true;
    }
    return false;
  }

  // ================= EDIT TASK =================
  Future<bool> editTask(
      int id, String title, String description, String? deadline) async {
    final success = await TaskService.updateTask(
        id, title, description, deadline ?? '', widget.token);
    if (success) {
      getTasks();
      return true;
    }
    return false;
  }

  // ================= DELETE =================
  Future<void> deleteTask(int id) async {
    final success = await TaskService.deleteTask(id, widget.token);
    if (success) {
      getTasks();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin mau keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');

              if (!nav.mounted) return;

              nav.pushAndRemoveUntil(
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
    showDialog(
      context: context,
      builder: (_) => _AddTaskDialog(
        onSave: addTask,
        formatDeadline: formatDeadline,
      ),
    );
  }

  // ================= EDIT DIALOG =================
  void showEditDialog(Task task) {
    showDialog(
      context: context,
      builder: (_) => _EditTaskDialog(
        task: task,
        onUpdate: editTask,
        formatDeadline: formatDeadline,
      ),
    );
  }

  // ================= UI DELETE CONFIRMATION =================
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus Task?"),
        content: const Text("Data akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final dialogNav = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(context);

              await deleteTask(id);

              if (dialogNav.mounted) dialogNav.pop();
              messenger.showSnackBar(
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
          : RefreshIndicator(
              onRefresh: getTasks,
              child: tasks.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            "Belum ada data\nTarik ke bawah untuk memuat ulang",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    )
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
                                Text(
                                    "Deadline: ${formatDeadline(task.deadline)}"),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(task.title),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Deskripsi: ${task.description}"),
                                      Text(
                                          "Deadline: ${formatDeadline(task.deadline)}"),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final Future<bool> Function(String, String, String?) onSave;
  final String Function(String?) formatDeadline;

  const _AddTaskDialog({required this.onSave, required this.formatDeadline});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Task"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleC,
              decoration: const InputDecoration(labelText: "Judul"),
              validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
            ),
            TextFormField(
              controller: _descC,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              onPressed: _isSaving
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date == null || !mounted) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time == null) return;

                      setState(() {
                        _selectedDateTime = DateTime(date.year, date.month,
                            date.day, time.hour, time.minute);
                      });
                    },
              label: Text(_selectedDateTime == null
                  ? "Pilih Tanggal & Jam"
                  : "Ubah: ${widget.formatDeadline(_selectedDateTime!.toIso8601String())}"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;

                  setState(() => _isSaving = true);
                  final messenger = ScaffoldMessenger.of(context);
                  final isSuccess = await widget.onSave(_titleC.text,
                      _descC.text, _selectedDateTime?.toIso8601String());

                  if (!mounted) return;
                  setState(() => _isSaving = false);

                  if (isSuccess) {
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text("Task berhasil ditambahkan!"),
                          backgroundColor: Colors.green),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text("Gagal menambah task!"),
                          backgroundColor: Colors.red),
                    );
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Simpan"),
        ),
      ],
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;
  final Future<bool> Function(int, String, String, String?) onUpdate;
  final String Function(String?) formatDeadline;

  const _EditTaskDialog(
      {required this.task,
      required this.onUpdate,
      required this.formatDeadline});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late TextEditingController _titleC;
  late TextEditingController _descC;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.task.title);
    _descC = TextEditingController(text: widget.task.description);
    _selectedDateTime = widget.task.deadline != null
        ? DateTime.tryParse(widget.task.deadline!)
        : null;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Task"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleC,
              decoration: const InputDecoration(labelText: "Judul"),
              validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
            ),
            TextFormField(
              controller: _descC,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_calendar),
              onPressed: _isSaving
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date == null || !mounted) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedDateTime != null
                            ? TimeOfDay.fromDateTime(_selectedDateTime!)
                            : TimeOfDay.now(),
                      );
                      if (time == null) return;

                      setState(() {
                        _selectedDateTime = DateTime(date.year, date.month,
                            date.day, time.hour, time.minute);
                      });
                    },
              label: Text(_selectedDateTime == null
                  ? "Pilih Tanggal & Jam"
                  : "Ubah: ${widget.formatDeadline(_selectedDateTime!.toIso8601String())}"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;

                  setState(() => _isSaving = true);
                  final messenger = ScaffoldMessenger.of(context);
                  final isSuccess = await widget.onUpdate(
                      widget.task.id,
                      _titleC.text,
                      _descC.text,
                      _selectedDateTime?.toIso8601String());

                  if (!mounted) return;
                  setState(() => _isSaving = false);

                  if (isSuccess) {
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text("Task berhasil diperbarui!"),
                          backgroundColor: Colors.green),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text("Gagal memperbarui task!"),
                          backgroundColor: Colors.red),
                    );
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Update"),
        ),
      ],
    );
  }
}
