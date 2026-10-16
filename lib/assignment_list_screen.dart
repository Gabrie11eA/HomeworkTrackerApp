import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

enum AssignmentFilter { all, completed, incomplete }

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _assignmentPresenter = AssignmentPresenter();
  final CoursePresenter _coursePresenter = CoursePresenter();

  bool _isLoading = true;

  String? _selectedCourseFilter;
  String? _newAssignmentCourse;
  List<String> _courseNames = [];

  AssignmentFilter _filter = AssignmentFilter.all;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
    _loadData();
  }

  Future<void> _loadData() async {
    await _coursePresenter.loadCourses();
    await _assignmentPresenter.loadAssignments();

    setState(() {
      _courseNames =
          _coursePresenter.courses.map((course) => course.name).toList();
    });
  }

  Future<void> _loadAssignments() async {
    await _assignmentPresenter.loadAssignments();
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';
    _newAssignmentCourse =
        _courseNames.isNotEmpty ? _courseNames.first : null;
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
                    decoration: const InputDecoration(
                      hintText: 'Enter assignment title',
                    ),
                    onChanged: (value) {
                      newAssignmentTitle = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _newAssignmentCourse,
                    onChanged: (value) {
                      setStateDialog(() {
                        _newAssignmentCourse = value;
                      });
                    },
                    items: _courseNames.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      );
                    }).toList(),
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
                    if (newAssignmentTitle.trim().isNotEmpty &&
                        _newAssignmentCourse != null) {
                      await _assignmentPresenter.addAssignment(
                        newAssignmentTitle.trim(),
                        _newAssignmentCourse!,
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
    final assignments = _assignmentPresenter.assignments;

    // COURSE FILTER LOGIC
    final displayedAssignments = _selectedCourseFilter == null
        ? assignments
        : assignments
            .where((a) => a.courseName == _selectedCourseFilter)
            .toList();

    // COMPLETION FILTER LOGIC
    final filteredAssignments = displayedAssignments.where((assignment) {
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
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          if (_courseNames.isNotEmpty)
            DropdownButton<String>(
              hint: const Text(
                'Filter by course',
                style: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.blue[100],
              value: _selectedCourseFilter,
              onChanged: (value) {
                setState(() {
                  _selectedCourseFilter = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Courses'),
                ),
                ..._courseNames.map(
                  (name) =>
                      DropdownMenuItem(value: name, child: Text(name)),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // COMPLETION FILTER DROPDOWN
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
                        subtitle: Text('Course: ${assignment.courseName}'),
                        value: assignment.isCompleted,
                        onChanged: (_) async {
                          await _assignmentPresenter.toggleCompleted(
                              assignment);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: AddFAB(
        onPressed: _showAddAssignmentDialog,
      ),
    );
  }
}