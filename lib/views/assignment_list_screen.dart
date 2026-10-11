import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';
import '../widgets/edit_button.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  final TextEditingController textController = TextEditingController();
  final CoursePresenter _coursePresenter = CoursePresenter();

  String? _selectedCourseFilter;
  String? _newAssignmentCourse;
  List<String> _courseNames = [];

  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _coursePresenter.loadCourses();
    await _presenter.loadAssignments();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _courseNames = _coursePresenter.courses.map((c) => c.name).toList();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _showAddAssignmentDialog() {
  String newAssignmentTitle = '';
  _newAssignmentCourse =
      _courseNames.isNotEmpty ? _courseNames.first : null;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Assignment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter Assignment Title',
                  ),
                  onChanged: (value) {
                    newAssignmentTitle = value;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: _newAssignmentCourse,
                  items: _courseNames.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(
                    () => _newAssignmentCourse = value,
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
                  if (newAssignmentTitle.trim().isNotEmpty &&
                      _newAssignmentCourse != null) {
                    await _presenter.addAssignment(
                      newAssignmentTitle.trim(),
                      _newAssignmentCourse!,
                    );

                    if (!mounted) return;

                    setState(() {});

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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

  void _showEditAssignment(int index) {
    textController.text = _presenter.assignments[index].title;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Assignment Title'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter Edited Assignment Name',
            ),
            controller: textController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  setState(() {
                    _presenter.assignments[index].title =
                        textController.text.trim();
                  });
                }

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  final assignments = _presenter.assignments;

  final courseAssignments = _selectedCourseFilter == null
      ? assignments
      : assignments
          .where((a) => a.courseName == _selectedCourseFilter)
          .toList();

  final displayedAssignments = courseAssignments.where((assignment) {
    if (_filter == 'Incomplete') {
      return !assignment.isCompleted;
    }

    if (_filter == 'Complete') {
      return assignment.isCompleted;
    }

    return true;
  }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          if (_courseNames.isNotEmpty)
            DropdownButton<String>(
              hint: const Text('Filter by course'),
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
                  (name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButton<String>(
                    value: _filter,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: 'Incomplete',
                        child: Text('Incomplete'),
                      ),
                      DropdownMenuItem(
                        value: 'Complete',
                        child: Text('Complete'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _filter = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = displayedAssignments[index];

                      // Use its original index, even when filtered.
                      final originalIndex =
                          _presenter.assignments.indexOf(assignment);

                      return ListTile(
                        subtitle: Text(
                          'Course: ${assignment.courseName}',
                        ),
                        title: Row(
                          children: [
                            Checkbox(
                              value: assignment.isCompleted,
                              onChanged: (_) async {
                                await _presenter.toggleCompleted(
                                  originalIndex,
                                );

                                if (!mounted) return;

                                setState(() {});
                              },
                            ),
                            EditButton(
                              onPressed: () => _showEditAssignment(originalIndex),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                assignment.title,
                                style: TextStyle(
                                  decoration: assignment.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await _presenter.deleteAssignment(
                                  originalIndex,
                                );

                                if (!mounted) return;

                                setState(() {});
                              },
                            ),
                          ],
                        ),
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
  }}