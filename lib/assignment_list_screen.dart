import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

enum AssignmentFilter { all, completed, incomplete }

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  bool _isLoading = true;

  AssignmentFilter _filter = AssignmentFilter.all;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Assignment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter assignment title',
                    ),
                    onChanged: (value) {
                      newAssignmentTitle = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      setStateDialog(() {
                        selectedDate = picked;
                      });
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Select Due Date'
                          : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (newAssignmentTitle.trim().isNotEmpty) {
                      await _presenter.addAssignment(
                        newAssignmentTitle.trim(),
                        selectedDate,
                      );
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;

    // FILTER LOGIC
    final filteredAssignments = assignments.where((assignment) {
      switch (_filter) {
        case AssignmentFilter.completed:
          return assignment.isCompleted;
        case AssignmentFilter.incomplete:
          return !assignment.isCompleted;
        case AssignmentFilter.all:
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // FILTER DROPDOWN
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<AssignmentFilter>(
                    value: _filter,
                    onChanged: (value) {
                      setState(() {
                        _filter = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: AssignmentFilter.all,
                        child: Text("All Assignments"),
                      ),
                      DropdownMenuItem(
                        value: AssignmentFilter.completed,
                        child: Text("Completed"),
                      ),
                      DropdownMenuItem(
                        value: AssignmentFilter.incomplete,
                        child: Text("Incomplete"),
                      ),
                    ],
                  ),
                ),

                // ASSIGNMENT LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = filteredAssignments[index];

                      return CheckboxListTile(
                        title: Text(assignment.title),
                        subtitle: assignment.dueDate != null
                            ? Text(
                                "Due: ${assignment.dueDate!.month}/${assignment.dueDate!.day}/${assignment.dueDate!.year}",
                              )
                            : null,
                        value: assignment.isCompleted,
                        onChanged: (_) async {
                          await _presenter.toggleCompleted(assignment);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
