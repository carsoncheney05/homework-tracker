import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  final TextEditingController textController = TextEditingController();

  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();

    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter Assignment Title',
            ),
            onChanged: (value) {
              newAssignmentTitle = value;
            },
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
                  );

                  if (!mounted) return;

                  setState(() {});
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
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
    final assignments = _presenter.assignments.where((assignment) {
      if (_filter == 'Incomplete') {
        return !assignment.isCompleted;
      }

      if (_filter == 'Complete') {
        return assignment.isCompleted;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
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
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];

                      // Use its original index, even when filtered.
                      final originalIndex =
                          _presenter.assignments.indexOf(assignment);

                      return ListTile(
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
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  _showEditAssignment(originalIndex),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}