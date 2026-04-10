import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'issue_detail_screen.dart';

class MyIssuesScreen extends StatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  State<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  final IssueService _issueService = IssueService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('My Reports',
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('నా రిపోర్ట్‌లు',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),

      // 🔥 STEP 1: Wait for user
      body: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, authSnapshot) {
          // ⏳ Loading
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Not logged in
          if (!authSnapshot.hasData) {
            return const Center(child: Text("User not logged in"));
          }

          // ✅ SAFE: user is NOT null here
          final user = authSnapshot.data!;

          // 🔥 STEP 2: Fetch issues using UID
          return StreamBuilder<List<Issue>>(
            stream: _issueService.getIssuesStream(userId: user.uid),
            builder: (context, snapshot) {
              // ⏳ Loading issues
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final issues = snapshot.data ?? [];

              // 📭 Empty state
              if (issues.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📋', style: TextStyle(fontSize: 60)),
                      SizedBox(height: 16),
                      Text('No reports yet',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('ఇంకా రిపోర్ట్‌లు లేవు',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // 📊 Stats
              final open =
                  issues.where((i) => i.status == IssueStatus.open).length;
              final resolved =
                  issues.where((i) => i.status == IssueStatus.resolved).length;
              final inProgress =
                  issues.where((i) => i.status == IssueStatus.inProgress).length;

              return Column(
                children: [
                  // 🔷 Stats Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF0E3A9E)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat('Total', '${issues.length}', '📋'),
                        _Stat('Open', '$open', '🔴'),
                        _Stat('In Progress', '$inProgress', '🟡'),
                        _Stat('Resolved', '$resolved', '🟢'),
                      ],
                    ),
                  ),

                  // 📃 Issues List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: issues.length,
                      itemBuilder: (ctx, i) {
                        final issue = issues[i];
                        final statusColor =
                            AppTheme.statusColor(issue.status.name);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    IssueDetailScreen(issueId: issue.id),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // 🧾 Category Icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        issue.category.categoryEmoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // 📌 Title & Date
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          issue.title,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM d, y')
                                              .format(issue.createdAt),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 🟢 Status
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Text(
                                      issue.statusLabel,
                                      style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// 📊 Stats Widget
class _Stat extends StatelessWidget {
  final String label, value, emoji;
  const _Stat(this.label, this.value, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}