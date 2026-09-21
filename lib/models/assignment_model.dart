class Assignment {
  final String title;
  bool isCompleted;
  DateTime? dueDate;

  Assignment({
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });
}
