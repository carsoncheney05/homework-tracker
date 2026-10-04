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

  Future<void> addAssignment(String title) async {
    final id = await Assignment.addAssignment(title);
    if (id == null) return;

    _assignments.add(Assignment(id: id, title: title));
  }

  Future<void> toggleCompleted(int index) async {
    await Assignment.updateCompletionStatus(index, _assignments);
    _assignments[index].isCompleted = !_assignments[index].isCompleted;
  }

  Future<void> deleteAssignment(int index) async {
    final assignment = _assignments[index];
    if (assignment.id == null) return;

    await Assignment.deleteAssignment(assignment.id!);
    _assignments.remove(assignment);
  }
}