import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;

  Future<void> loadAssignments() async {
    final fetched = await Assignment.fetchAssignments();
    _assignments
      ..clear()
      ..addAll(fetched);
  }

  Future<void> addAssignment(String title, String courseName, DateTime? dueDate) async {
    final newAssignment = await Assignment.addAssignment(title, courseName, dueDate);
    if (newAssignment != null) {
      _assignments.add(newAssignment);
    }
  }

  Future<void> toggleCompleted(Assignment assignment) async {
    final newValue = !assignment.isCompleted;
    await Assignment.updateCompletionStatus(assignment.id, newValue);
    assignment.isCompleted = newValue;
  }

  Future<void> deleteAssignment(Assignment assignment) async {
    await Assignment.deleteAssignment(assignment.id);
    _assignments.remove(assignment);
  }
}
