import 'package:flutter/material.dart';
import 'package:homework_tracker/presenters/assignment_presenter.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();
    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = _presenter.completionRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Tracker'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Circular percent indicator
                  Center(
                    child: CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 10.0,
                      percent: percent,
                      center: Text(
                        '${(percent * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.purple,
                      backgroundColor: Colors.grey.shade300,
                      animation: true,
                      animationDuration: 800,
                      footer: const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Assignments Completed'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Total assignments card
                  Card(
                    child: ListTile(
                      title: const Text('Total Assignments'),
                      trailing: Text('${_presenter.totalAssignments}'),
                    ),
                  ),

                  // Completed assignments card
                  Card(
                    child: ListTile(
                      title: const Text('Completed Assignments'),
                      trailing: Text('${_presenter.completedAssignments}'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⭐ Animated progress bar (Option 2)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fullWidth = constraints.maxWidth;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        height: 10,
                        width: fullWidth * percent,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}