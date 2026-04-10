import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'issue_detail_screen.dart';

class IssuesListScreen extends StatefulWidget {
  const IssuesListScreen({super.key});

  @override
  State<IssuesListScreen> createState() => _IssuesListScreenState();
}

class _IssuesListScreenState extends State<IssuesListScreen> {
  final _issueService = IssueService();
  final _authService = AuthService();
  IssueStatus? _statusFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('All Issues', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('అన్ని సమస్యలు',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search issues / సమస్యలు వెతకండి...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          if (_statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(_statusFilter!.name),
                    selected: true,
                    onSelected: (_) => setState(() => _statusFilter = null),
                    onDeleted: () => setState(() => _statusFilter = null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Issue>>(
              stream: _issueService.getIssuesStream(statusFilter: _statusFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var issues = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  issues = issues
                      .where((i) =>
                          i.title.toLowerCase().contains(_searchQuery) ||
                          i.description.toLowerCase().contains(_searchQuery) ||
                          i.address.toLowerCase().contains(_searchQuery))
                      .toList();
                }
                if (issues.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No issues found',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                        Text('సమస్యలు కనుగొనబడలేదు',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: issues.length,
                  itemBuilder: (ctx, i) {
                    final issue = issues[i];
                    final hasUpvoted = issue.upvotedBy
                        .contains(_authService.currentUser?.uid ?? '');
                    final statusColor = AppTheme.statusColor(issue.status.name);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueDetailScreen(issueId: issue.id),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(issue.category.categoryEmoji,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(issue.title,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(issue.statusLabel,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: statusColor)),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.priorityColor(
                                                    issue.priority.name)
                                                .withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(issue.priorityLabel,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.priorityColor(
                                                      issue.priority.name))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 12,
                                            color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(issue.address,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM d, y').format(issue.createdAt),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => _issueService.toggleUpvote(
                                        issue.id,
                                        _authService.currentUser?.uid ?? ''),
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
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter / ఫిల్టర్',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('Status / స్థితి',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: IssueStatus.values
                  .map((s) => ChoiceChip(
                        label: Text(s.name),
                        selected: _statusFilter == s,
                        onSelected: (selected) {
                          setState(() => _statusFilter = selected ? s : null);
                          Navigator.pop(ctx);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}