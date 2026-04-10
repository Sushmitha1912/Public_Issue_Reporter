import 'package:flutter/material.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'report_issue_screen.dart';
import 'issues_list_screen.dart';
import 'my_issues_screen.dart';
import 'profile_screen.dart';
import 'issue_detail_screen.dart' as detail;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const _HomeTab(),
    const ReportIssueScreen(),
    const IssuesListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outlined),
            selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primary),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: AppTheme.primary),
            label: 'Issues',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final issueService = IssueService();
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A56DB), Color(0xFF0E3A9E)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Row(
                  children: [
                    const Text('📢', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Public Reporter',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          Text('పబ్లిక్ రిపోర్టర్',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    const Icon(Icons.person_outline, color: Colors.white),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Report Your\nIssues Here!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3)),
                            SizedBox(height: 4),
                            Text('మీ సమస్యలను ఇక్కడ రిపోర్ట్ చేయండి!',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('🏙️', style: TextStyle(fontSize: 60)),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _ActionBtn(
                      emoji: '📷',
                      title: 'Photo Upload',
                      telugu: 'ఫోటో అప్‌లోడ్',
                      color: const Color(0xFFFF6B35),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ReportIssueScreen())),
                    ),
                    _ActionBtn(
                      emoji: '📍',
                      title: 'Issue Location',
                      telugu: 'సమస్య లొకేషన్',
                      color: const Color(0xFF10B981),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ReportIssueScreen())),
                    ),
                    _ActionBtn(
                      emoji: '📋',
                      title: 'Issue Details',
                      telugu: 'సమస్య వివరాలు',
                      color: const Color(0xFFEF4444),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const IssuesListScreen())),
                    ),
                    _ActionBtn(
                      emoji: '💬',
                      title: 'My Reports',
                      telugu: 'నా రిపోర్ట్‌లు',
                      color: const Color(0xFF3B82F6),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MyIssuesScreen())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Trending Reports / ట్రెండింగ్ రిపోర్ట్స్',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              StreamBuilder<List<Issue>>(
                stream: issueService.getIssuesStream(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final issues = snap.data!.take(5).toList();
                  if (issues.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No issues yet\nఇంకా సమస్యలు లేవు',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: issues.length,
                    itemBuilder: (c, i) {
                      final issue = issues[i];
                      final hasUpvoted = issue.upvotedBy.contains(user?.uid ?? '');
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                  builder: (_) => detail.IssueDetailScreen(
                                      issueId: issue.id))),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: issue.imageUrls.isNotEmpty
                                      ? Image.network(
                                          issue.imageUrls.first,
                                          width: 70, height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 70, height: 70,
                                            color: Colors.grey.shade200,
                                            child: Center(
                                                child: Text(issue.category.categoryEmoji,
                                                    style: const TextStyle(fontSize: 30))),
                                          ))
                                      : Container(
                                          width: 70, height: 70,
                                          color: AppTheme.primary.withOpacity(0.1),
                                          child: Center(
                                              child: Text(issue.category.categoryEmoji,
                                                  style: const TextStyle(fontSize: 30))),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(issue.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text('By: ${issue.reporterName}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.statusColor(issue.status.name)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(issue.statusLabel,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.statusColor(issue.status.name),
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => issueService.toggleUpvote(
                                          issue.id, user?.uid ?? ''),
                                      child: Icon(
                                        hasUpvoted
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: hasUpvoted ? Colors.red : Colors.grey,
                                        size: 22,
                                      ),
                                    ),
                                    Text('${issue.upvotes}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String emoji, title, telugu;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.emoji,
    required this.title,
    required this.telugu,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Text(telugu,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}