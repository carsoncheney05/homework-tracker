import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  String? id;
  String title;
  bool isCompleted;

  Assignment({
    this.id,
    required this.title,
    this.isCompleted = false,
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
            isCompleted: value['isCompleted'],
          ),
        );
      });
    }

    return assignments;
  }

  static Future<String?> addAssignment(String title) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final newRef = _db.child('assignments/$userId').push();

    await newRef.set({
      'title': title,
      'isCompleted': false,
    });

    return newRef.key;
  }

  static Future<void> updateCompletionStatus(
    int index,
    List<Assignment> currentAssignments,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null ||
        index < 0 ||
        index >= currentAssignments.length) {
      return;
    }

    final assignment = currentAssignments[index];
    if (assignment.id == null) return;

    final ref = _db.child('assignments/$userId/${assignment.id}');
    final updatedStatus = !assignment.isCompleted;

    await ref.update({'isCompleted': updatedStatus});
  }

  static Future<void> deleteAssignment(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.child('assignments/$userId/$id').remove();
  }
}