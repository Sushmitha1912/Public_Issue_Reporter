import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/issue.dart';
import 'package:uuid/uuid.dart';

class IssueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _issues => _firestore.collection('issues');

  Stream<List<Issue>> getIssuesStream({
    IssueStatus? statusFilter,
    IssueCategory? categoryFilter,
    String? userId,
  }) {
    Query query = _issues;

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.name);
    } else if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter.name);
    } else if (userId != null) {
      query = query.where('reportedBy', isEqualTo: userId);
    }

    return query.snapshots().map((snap) {
      final list = snap.docs.map((doc) => Issue.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<Issue?> getIssueStream(String issueId) {
    return _issues.doc(issueId).snapshots().map((doc) {
      if (doc.exists) return Issue.fromFirestore(doc);
      return null;
    });
  }

  Future<Issue?> getIssue(String issueId) async {
    final doc = await _issues.doc(issueId).get();
    if (doc.exists) return Issue.fromFirestore(doc);
    return null;
  }

  Future<String> createIssue({
    required String title,
    required String description,
    required IssueCategory category,
    required IssuePriority priority,
    required double latitude,
    required double longitude,
    required String address,
    required List<String> imageUrls, // ✅ Cloudinary URLs directly
    required String userId,
    required String userName,
  }) async {
    final issueId = _uuid.v4();
    final now = DateTime.now();

    final issue = Issue(
      id: issueId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: IssueStatus.open,
      latitude: latitude,
      longitude: longitude,
      address: address,
      imageUrls: imageUrls, // ✅ already uploaded URLs
      reportedBy: userId,
      reporterName: userName,
      createdAt: now,
      updatedAt: now,
      upvotes: 0,
      upvotedBy: [],
    );

    await _issues.doc(issueId).set(issue.toFirestore());
    return issueId;
  }

  Future<void> updateIssueStatus(String issueId, IssueStatus status) async {
    await _issues.doc(issueId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> toggleUpvote(String issueId, String userId) async {
    final doc = await _issues.doc(issueId).get();
    final data = doc.data() as Map<String, dynamic>;
    final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
    if (upvotedBy.contains(userId)) {
      upvotedBy.remove(userId);
    } else {
      upvotedBy.add(userId);
    }
    await _issues.doc(issueId).update({
      'upvotedBy': upvotedBy,
      'upvotes': upvotedBy.length,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteIssue(String issueId) async {
    await _issues.doc(issueId).delete();
  }
}