import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/issue.dart';

class IssueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  static const String _cloudName = 'dqmlxpime';
  static const String _uploadPreset = 'flutter_upload';

  CollectionReference get _issues => _firestore.collection('issues');

  Stream<List<Issue>> getIssuesStream({
    IssueStatus? statusFilter,
    IssueCategory? categoryFilter,
    String? userId,
  }) {
    Query query = _issues.orderBy('createdAt', descending: true);
    if (statusFilter != null)
      query = query.where('status', isEqualTo: statusFilter.name);
    if (categoryFilter != null)
      query = query.where('category', isEqualTo: categoryFilter.name);
    if (userId != null)
      query = query.where('reportedBy', isEqualTo: userId);
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => Issue.fromFirestore(doc)).toList());
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
    required List<XFile> images,
    required String userId,
    required String userName,
  }) async {
    final issueId = _uuid.v4();
    final imageUrls = <String>[];

    for (int i = 0; i < images.length; i++) {
      final url = await _uploadImageToCloudinary(images[i]);
      if (url != null) {
        imageUrls.add(url);
        print('✅ Image $i uploaded: $url');
      } else {
        print('❌ Image $i upload failed');
      }
    }

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
      imageUrls: imageUrls,
      reportedBy: userId,
      reporterName: userName,
      createdAt: now,
      updatedAt: now,
      upvotes: 0,
      upvotedBy: [],
    );

    await _issues.doc(issueId).set(issue.toFirestore());
    print('✅ Issue saved to Firestore with ${imageUrls.length} images');
    return issueId;
  }

  Future<String?> _uploadImageToCloudinary(XFile file) async {
  try {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final response = await http.post(
     uri,
     body: {
        'file': 'data:image/jpeg;base64,$base64Image',
        'upload_preset': _uploadPreset,
        'public_id': 'issue${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    final jsonResponse = jsonDecode(response.body);
    print('📡 Status: ${response.statusCode}');
    print('📡 Response: $jsonResponse');

    if (response.statusCode == 200) {
      return jsonResponse['secure_url'] as String;
    }
    return null;
  } catch (e) {
    print('❌ Upload error: $e');
    return null;
  }
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