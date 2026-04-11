import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(double lat, double lon) async {
  final Uri googleUrl = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
  );

  final Uri geoUrl = Uri.parse("geo:$lat,$lon?q=$lat,$lon");

  if (!await launchUrl(googleUrl,
      mode: LaunchMode.externalApplication)) {
    await launchUrl(geoUrl);
  }
}

class IssueDetailScreen extends StatelessWidget {
  final String issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    final issueService = IssueService();
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Issue Details',
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('సమస్య వివరాలు',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: FutureBuilder<Issue?>(
        future: issueService.getIssue(issueId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Issue not found'));
          }
          final issue = snapshot.data!;
          final hasUpvoted = issue.upvotedBy.contains(user?.uid ?? '');
          final isOwner = issue.reportedBy == user?.uid;
          final statusColor = AppTheme.statusColor(issue.status.name);
          final emoji = issue.category.categoryEmoji;
          final label = issue.category.categoryLabel;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images
                if (issue.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: issue.imageUrls.length,
                      itemBuilder: (_, i) => Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            issue.imageUrls[i],
                            width: 280,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 280,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 280,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Title + Status
                Row(
                  children: [
                    Expanded(
                      child: Text(issue.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(issue.statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category + Priority
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.priorityColor(issue.priority.name)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(issue.priorityLabel,
                          style: TextStyle(
                              color: AppTheme.priorityColor(
                                  issue.priority.name),
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                const Text('Description / వివరణ',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey)),
                const SizedBox(height: 6),
                Text(issue.description,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
                const SizedBox(height: 16),

                // Location
                const Text('Location / లొకేషన్',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(issue.address,
                          style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                 onPressed: () {
                    openMap(issue.latitude, issue.longitude);
                  },
                  icon: Icon(Icons.map),
                  label: Text("View on Map 📍"),
            ),
               
                 
                
                const SizedBox(height: 16),

                // Reporter + Date
                Row(
                  children: [
                    const Icon(Icons.person_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('By: ${issue.reporterName}',
                        style: TextStyle(color: Colors.grey.shade600)),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y').format(issue.createdAt),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upvote Button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => issueService.toggleUpvote(
                            issue.id, user?.uid ?? ''),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              hasUpvoted ? Colors.red : Colors.grey,
                          side: BorderSide(
                              color: hasUpvoted
                                  ? Colors.red
                                  : Colors.grey.shade300),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(hasUpvoted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded),
                        label: Text('${issue.upvotes} Upvotes',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),

                // Status Update (owner only)
                if (isOwner) ...[
                  const SizedBox(height: 16),
                  const Text('Update Status / స్థితి నవీకరించండి',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: IssueStatus.values.map((s) {
                      final selected = issue.status == s;
                      final color = AppTheme.statusColor(s.name);
                      return ChoiceChip(
                        label: Text(s.name),
                        selected: selected,
                        selectedColor: color.withOpacity(0.2),
                        onSelected: (_) =>
                            issueService.updateIssueStatus(issue.id, s),
                        labelStyle: TextStyle(
                          color: selected ? color : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}