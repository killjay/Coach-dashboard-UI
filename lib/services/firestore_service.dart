import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/app_exceptions.dart';

/// Base Firestore service with generic CRUD operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a single document
  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final doc = await _firestore.doc(path).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw FirestoreException('Failed to get document: $e');
    }
  }

  /// Stream a single document
  Stream<Map<String, dynamic>?> streamDocument(String path) {
    try {
      return _firestore.doc(path).snapshots().map((doc) {
        return doc.exists ? doc.data() : null;
      });
    } catch (e) {
      throw FirestoreException('Failed to stream document: $e');
    }
  }

  /// Set a document (create or overwrite)
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    try {
      await _firestore.doc(path).set(data);
    } catch (e) {
      throw FirestoreException('Failed to set document: $e');
    }
  }

  /// Update a document (merge)
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      await _firestore.doc(path).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update document: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String path) async {
    try {
      await _firestore.doc(path).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete document: $e');
    }
  }

  /// Get a collection
  Future<List<Map<String, dynamic>>> getCollection(String path) async {
    try {
      final snapshot = await _firestore.collection(path).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw FirestoreException('Failed to get collection: $e');
    }
  }

  /// Stream a collection
  Stream<List<Map<String, dynamic>>> streamCollection(String path) {
    try {
      return _firestore.collection(path).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      throw FirestoreException('Failed to stream collection: $e');
    }
  }

  /// Query a collection
  Future<List<Map<String, dynamic>>> queryCollection(
    String path, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(path);

      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw FirestoreException('Failed to query collection: $e');
    }
  }

  /// Stream a query
  Stream<List<Map<String, dynamic>>> streamQuery(
    String path, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    try {
      Query query = _firestore.collection(path);

      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      throw FirestoreException('Failed to stream query: $e');
    }
  }

  /// Batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        switch (op.type) {
          case BatchOperationType.set:
            batch.set(_firestore.doc(op.path), op.data!);
            break;
          case BatchOperationType.update:
            batch.update(_firestore.doc(op.path), op.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(_firestore.doc(op.path));
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to execute batch write: $e');
    }
  }

  /// Generate a new document ID
  String generateId(String collectionPath) {
    return _firestore.collection(collectionPath).doc().id;
  }
}

enum BatchOperationType { set, update, delete }

class BatchOperation {
  final BatchOperationType type;
  final String path;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.path,
    this.data,
  });
}

