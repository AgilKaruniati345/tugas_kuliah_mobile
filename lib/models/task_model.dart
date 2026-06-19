class Task {
  final int id;
  final String title;

  Task({required this.id, required this.title});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(id: json['id'], title: json['title'] ?? '');
  }
}
