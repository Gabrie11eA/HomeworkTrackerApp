import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String id;
  final String title;
  bool isCompleted;
  DateTime? dueDate;

  Assignment({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  static Future<List<Assignment>> fetchAssignments() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _db.child('assignments/$userId').get();
    final List<Assignment> assignments = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        assignments.add(
          Assignment(
            id: key,
            title: value['title'],
            isCompleted: value['isCompleted'] ?? false,
            dueDate: value['dueDate'] != null
                ? DateTime.parse(value['dueDate'])
                : null,
          ),
        );
      });
    }

    return assignments;
  }

  static Future<Assignment?> addAssignment(String title, DateTime? dueDate) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final newRef = _db.child('assignments/$userId').push();

    await newRef.set({
      'title': title,
      'isCompleted': false,
      'dueDate': dueDate?.toIso8601String(),
    });

    return Assignment(
      id: newRef.key!,
      title: title,
      isCompleted: false,
      dueDate: dueDate,
    );
  }

  static Future<void> updateCompletionStatus(String id, bool newValue) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.child('assignments/$userId/$id').update({
      'isCompleted': newValue,
    });
  }

  static Future<void> deleteAssignment(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.child('assignments/$userId/$id').remove();
  }
}
