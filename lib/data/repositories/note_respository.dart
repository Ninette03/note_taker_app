import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_taker_app/data/models/note_model.dart';
import 'package:uuid/uuid.dart';

abstract class NoteRepository {
  Future<List<NoteModel>> fetchNotes();
  Future<void> addNote(String text);
  Future<void> updateNote(String id, String text);
  Future<void> deleteNote(String id);
}

class NoteRepositoryImpl implements NoteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NoteRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  @override
  Future<List<NoteModel>> fetchNotes() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => NoteModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> addNote(String text) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    
    final id = const Uuid().v4();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(id)
        .set({
          'id': id,
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateNote(String id, String text) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(id)
        .update({'text': text});
  }

  @override
  Future<void> deleteNote(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(id)
        .delete();
  }
}