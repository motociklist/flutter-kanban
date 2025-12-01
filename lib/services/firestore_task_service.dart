import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/kanban_task.dart';

class FirestoreTaskService {
  static final _instance = FirestoreTaskService._internal();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  factory FirestoreTaskService() => _instance;
  FirestoreTaskService._internal();

  String get _uid => _auth.currentUser?.uid ?? '';

  bool get isAuthenticated => _auth.currentUser != null;

  CollectionReference<Map<String, dynamic>> get _tasksCol {
    if (!isAuthenticated) {
      throw StateError('No authenticated user; cannot access tasks collection');
    }
    return _firestore.collection('users').doc(_uid).collection('tasks');
  }

  Future<void> addTask(KanbanTask task) async {
    if (!isAuthenticated) throw StateError('User not logged in');
    await _tasksCol.doc(task.id).set(_toMap(task));
  }

  Future<void> updateTask(KanbanTask task) async {
    if (!isAuthenticated) throw StateError('User not logged in');
    await _tasksCol.doc(task.id).update(_toMap(task));
  }

  Future<void> deleteTask(String id) async {
    if (!isAuthenticated) throw StateError('User not logged in');
    await _tasksCol.doc(id).delete();
  }

  Future<List<KanbanTask>> fetchTasks() async {
    if (!isAuthenticated) return [];
    final snap = await _tasksCol.get();
    return snap.docs.map((d) => _fromMap(d.data())).toList();
  }

  Stream<List<KanbanTask>> tasksStream() {
    if (!isAuthenticated) return const Stream.empty();
    return _tasksCol
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromMap(d.data())).toList());
  }

  Map<String, dynamic> _toMap(KanbanTask t) => {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'status': t.status.index,
        'color': t.color?.toARGB32(),
        'createdAt': t.createdAt.millisecondsSinceEpoch,
        'deadline': t.deadline?.millisecondsSinceEpoch,
        'createdBy': t.createdBy,
      };

  KanbanTask _fromMap(Map<String, dynamic> map) => KanbanTask(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        status: KanbanStatus.values[map['status'] ?? 0],
        color: map['color'] != null ? Color(map['color']) : null,
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
            : DateTime.now(),
        deadline: map['deadline'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
            : null,
        createdBy: map['createdBy'],
      );
}
