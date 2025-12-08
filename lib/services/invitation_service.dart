import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';
import 'user_service.dart';

class InvitationService {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a unique invitation code
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new invitation
  Future<Result<InvitationModel>> createInvitation({
    required String coachId,
    String? email,
  }) async {
    try {
      // Generate unique code
      String code = _generateInvitationCode();
      
      // Ensure code is unique (check if exists)
      bool codeExists = true;
      int attempts = 0;
      while (codeExists && attempts < 10) {
        final existing = await _firestoreService.queryCollection(
          'invitations',
          whereField: 'code',
          whereValue: code,
          limit: 1,
        );
        if (existing.isEmpty) {
          codeExists = false;
        } else {
          code = _generateInvitationCode();
          attempts++;
        }
      }

      if (codeExists) {
        return const Failure('Failed to generate unique invitation code');
      }

      // Create invitation document
      final inviteId = _firestoreService.generateId('invitations');
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 30));

      final invitation = InvitationModel(
        id: inviteId,
        coachId: coachId,
        code: code,
        email: email,
        createdAt: now,
        expiresAt: expiresAt,
        used: false,
      );

      await _firestoreService.setDocument(
        'invitations/$inviteId',
        invitation.toJson(),
      );

      return Success(invitation);
    } catch (e) {
      return Failure('Failed to create invitation: $e');
    }
  }

  /// Get invitation by code
  Future<Result<InvitationModel>> getInvitationByCode(String code) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'invitations',
        whereField: 'code',
        whereValue: code,
        limit: 1,
      );

      if (dataList.isEmpty) {
        return const Failure('Invitation not found');
      }

      final invitation = InvitationModel.fromJson(dataList.first);

      // Validate invitation
      if (invitation.used) {
        return const Failure('This invitation has already been used');
      }

      if (invitation.isExpired) {
        return const Failure('This invitation has expired');
      }

      return Success(invitation);
    } catch (e) {
      return Failure('Failed to get invitation: $e');
    }
  }

  /// Accept an invitation (transactional)
  Future<Result<void>> acceptInvitation(String code, String clientId) async {
    try {
      // First, get the invitation document ID (queries can't be used in transactions)
      final inviteQuery = _firestore
          .collection('invitations')
          .where('code', isEqualTo: code)
          .limit(1);
      
      final inviteQuerySnapshot = await inviteQuery.get();
      
      if (inviteQuerySnapshot.docs.isEmpty) {
        return const Failure('Invitation not found');
      }

      final inviteDocRef = inviteQuerySnapshot.docs.first.reference;
      final inviteData = inviteQuerySnapshot.docs.first.data();

      // Validate invitation before transaction
      if (inviteData['used'] == true) {
        return const Failure('Invitation already used');
      }

      final expiresAt = (inviteData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        return const Failure('Invitation expired');
      }

      // Now run the transaction with the document reference
      await _firestore.runTransaction((transaction) async {
        // 1. Re-read invitation in transaction to ensure it's still valid
        final inviteDoc = await transaction.get(inviteDocRef);
        
        if (!inviteDoc.exists) {
          throw Exception('Invitation not found');
        }

        final inviteDataInTransaction = inviteDoc.data() as Map<String, dynamic>;
        
        if (inviteDataInTransaction['used'] == true) {
          throw Exception('Invitation already used');
        }

        final coachIdFromTransaction = inviteDataInTransaction['coachId'] as String;

        // 2. Mark invitation as used
        transaction.update(inviteDocRef, {
          'used': true,
          'usedBy': clientId,
          'usedAt': FieldValue.serverTimestamp(),
        });

        // 3. Link client to coach
        final clientRef = _firestore.doc('clients/$clientId');
        transaction.update(clientRef, {
          'coachId': coachIdFromTransaction,
        });

        // 4. Add client to coach's list
        final coachRef = _firestore.doc('coaches/$coachIdFromTransaction');
        final coachDoc = await transaction.get(coachRef);
        
        if (!coachDoc.exists) {
          throw Exception('Coach not found');
        }

        final coachData = coachDoc.data() as Map<String, dynamic>;
        final currentClientIds = List<String>.from(
          coachData['clientIds'] ?? [],
        );
        
        // Only add if not already in list
        if (!currentClientIds.contains(clientId)) {
          currentClientIds.add(clientId);
          transaction.update(coachRef, {
            'clientIds': currentClientIds,
          });
        }
      });

      return const Success(null);
    } catch (e) {
      return Failure('Failed to accept invitation: ${e.toString()}');
    }
  }

  /// Get all invitations for a coach
  Future<Result<List<InvitationModel>>> getInvitationsByCoach(
    String coachId,
  ) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'invitations',
        whereField: 'coachId',
        whereValue: coachId,
        orderBy: 'createdAt',
        descending: true,
      );

      final invitations = dataList
          .map((data) => InvitationModel.fromJson(data))
          .toList();

      return Success(invitations);
    } catch (e) {
      return Failure('Failed to get invitations: $e');
    }
  }

  /// Stream invitations for a coach (real-time)
  Stream<List<InvitationModel>> streamInvitationsByCoach(String coachId) {
    return _firestoreService
        .streamQuery(
          'invitations',
          whereField: 'coachId',
          whereValue: coachId,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((dataList) {
      return dataList.map((data) => InvitationModel.fromJson(data)).toList();
    });
  }
}
