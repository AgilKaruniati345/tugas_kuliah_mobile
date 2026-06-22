class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? deadline;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.deadline,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'belum selesai',
      deadline: json['deadline'],
    );
  }
}
