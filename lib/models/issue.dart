import 'package:cloud_firestore/cloud_firestore.dart';

enum IssueStatus { open, inProgress, resolved, closed }
enum IssuePriority { low, medium, high, critical }
enum IssueCategory {
  roadDamage, streetLight, garbage, waterSupply,
  drainage, electricity, publicProperty, other,
}

extension IssueCategoryExtension on IssueCategory {
  String get categoryLabel {
    switch (this) {
      case IssueCategory.roadDamage: return 'Road Damage';
      case IssueCategory.streetLight: return 'Street Light';
      case IssueCategory.garbage: return 'Garbage';
      case IssueCategory.waterSupply: return 'Water Supply';
      case IssueCategory.drainage: return 'Drainage';
      case IssueCategory.electricity: return 'Electricity';
      case IssueCategory.publicProperty: return 'Public Property';
      case IssueCategory.other: return 'Other';
    }
  }

  String get categoryEmoji {
    switch (this) {
      case IssueCategory.roadDamage: return '🛣️';
      case IssueCategory.streetLight: return '💡';
      case IssueCategory.garbage: return '🗑️';
      case IssueCategory.waterSupply: return '💧';
      case IssueCategory.drainage: return '🌊';
      case IssueCategory.electricity: return '⚡';
      case IssueCategory.publicProperty: return '🏛️';
      case IssueCategory.other: return '📌';
    }
  }
}

class Issue {
  final String id;
  final String title;
  final String description;
  final IssueCategory category;
  final IssuePriority priority;
  final IssueStatus status;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> imageUrls;
  final String reportedBy;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvotes;
  final List<String> upvotedBy;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageUrls,
    required this.reportedBy,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    required this.upvotes,
    required this.upvotedBy,
  });

  factory Issue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Issue(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: IssueCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => IssueCategory.other,
      ),
      priority: IssuePriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => IssuePriority.medium,
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => IssueStatus.open,
      ),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      reportedBy: data['reportedBy'] ?? '',
      reporterName: data['reporterName'] ?? 'Anonymous',
      // ✅ FIXED: null-safe timestamp parsing
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      upvotes: data['upvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'imageUrls': imageUrls,
      'reportedBy': reportedBy,
      'reporterName': reporterName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
    };
  }

  String get statusLabel {
    switch (status) {
      case IssueStatus.open: return 'Open';
      case IssueStatus.inProgress: return 'In Progress';
      case IssueStatus.resolved: return 'Resolved';
      case IssueStatus.closed: return 'Closed';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case IssuePriority.low: return 'Low';
      case IssuePriority.medium: return 'Medium';
      case IssuePriority.high: return 'High';
      case IssuePriority.critical: return 'Critical';
    }
  }
}