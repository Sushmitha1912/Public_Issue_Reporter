import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../theme.dart';
import 'profile_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AdminDashboard(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFF6B35).withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFFFF6B35)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFFFF6B35)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AdminDashboard extends StatefulWidget {
  const _AdminDashboard();
  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard> {
  final _issueService = IssueService();
  IssueStatus? _statusFilter;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: StreamBuilder<List<Issue>>(
          // ✅ FIX: No filters here — always fetch ALL issues so counts are correct
          stream: _issueService.getIssuesStream(),
          builder: (context, allSnapshot) {
            // ✅ FIX: Show loading indicator while waiting for first data
            if (allSnapshot.connectionState == ConnectionState.waiting &&
                !allSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allIssues = allSnapshot.data ?? [];

            // ✅ These counts now always reflect the latest Firestore data via stream
            final open =
                allIssues.where((i) => i.status == IssueStatus.open).length;
            final inProgress = allIssues
                .where((i) => i.status == IssueStatus.inProgress)
                .length;
            final resolved = allIssues
                .where((i) => i.status == IssueStatus.resolved)
                .length;

            var filteredIssues = _statusFilter != null
                ? allIssues.where((i) => i.status == _statusFilter).toList()
                : allIssues;

            if (_searchQuery.isNotEmpty) {
              filteredIssues = filteredIssues
                  .where((i) =>
                      i.title.toLowerCase().contains(_searchQuery) ||
                      i.description.toLowerCase().contains(_searchQuery))
                  .toList();
            }

            return Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFE85D20)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: const Row(
                    children: [
                      Text('🛡️', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Dashboard',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          Text('నిర్వాహక డాష్‌బోర్డ్',
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats
                Container(
                  color: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _StatCard('Total', '${allIssues.length}', '📋', Colors.white),
                      const SizedBox(width: 8),
                      _StatCard('Open', '$open', '🔴', Colors.white),
                      const SizedBox(width: 8),
                      _StatCard('Progress', '$inProgress', '🟡', Colors.white),
                      const SizedBox(width: 8),
                      _StatCard('Resolved', '$resolved', '🟢', Colors.white),
                    ],
                  ),
                ),

                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search issues...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                  ),
                ),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _AdminFilterChip(
                        label: 'All',
                        selected: _statusFilter == null,
                        color: Colors.grey,
                        onTap: () => setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _AdminFilterChip(
                        label: '🔴 Open',
                        selected: _statusFilter == IssueStatus.open,
                        color: AppTheme.danger,
                        onTap: () =>
                            setState(() => _statusFilter = IssueStatus.open),
                      ),
                      const SizedBox(width: 8),
                      _AdminFilterChip(
                        label: '🟡 In Progress',
                        selected: _statusFilter == IssueStatus.inProgress,
                        color: AppTheme.warning,
                        onTap: () => setState(
                            () => _statusFilter = IssueStatus.inProgress),
                      ),
                      const SizedBox(width: 8),
                      _AdminFilterChip(
                        label: '🟢 Resolved',
                        selected: _statusFilter == IssueStatus.resolved,
                        color: AppTheme.success,
                        onTap: () =>
                            setState(() => _statusFilter = IssueStatus.resolved),
                      ),
                      const SizedBox(width: 8),
                      _AdminFilterChip(
                        label: '⚫ Closed',
                        selected: _statusFilter == IssueStatus.closed,
                        color: Colors.grey,
                        onTap: () =>
                            setState(() => _statusFilter = IssueStatus.closed),
                      ),
                    ],
                  ),
                ),

                // Issues List
                Expanded(
                  child: filteredIssues.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('📭', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 12),
                              Text('No issues found',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: filteredIssues.length,
                          itemBuilder: (ctx, i) {
                            final issue = filteredIssues[i];
                            final statusColor =
                                AppTheme.statusColor(issue.status.name);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminIssueDetailScreen(
                                        issueId: issue.id),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B35)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                              issue.category.categoryEmoji,
                                              style: const TextStyle(
                                                  fontSize: 24)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(issue.title,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            const SizedBox(height: 4),
                                            Text('By: ${issue.reporterName}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.grey.shade500)),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('MMM d, y')
                                                  .format(issue.createdAt),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border:
                                                  Border.all(color: statusColor),
                                            ),
                                            child: Text(issue.statusLabel,
                                                style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          const SizedBox(height: 6),
                                          const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 14,
                                              color: Colors.grey),
                                        ],
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
        ),
      ),
    );
  }
}

// ✅ FIXED: All status buttons now use async/await properly
class AdminIssueDetailScreen extends StatefulWidget {
  final String issueId;
  const AdminIssueDetailScreen({super.key, required this.issueId});

  @override
  State<AdminIssueDetailScreen> createState() =>
      _AdminIssueDetailScreenState();
}

class _AdminIssueDetailScreenState extends State<AdminIssueDetailScreen> {
  final issueService = IssueService();
  bool _isUpdating = false; // ✅ NEW: prevents double-taps during update

  // ✅ FIX: Central async update method with error handling
  Future<void> _updateStatus(IssueStatus newStatus, String label,
      Color color) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      await issueService.updateIssueStatus(widget.issueId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $label!'),
            backgroundColor: color,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        title: const Column(
          children: [
            Text('Issue Details',
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('సమస్య వివరాలు',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: StreamBuilder<Issue?>(
        stream: issueService.getIssueStream(widget.issueId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Issue not found'));
          }
          final issue = snapshot.data!;
          final statusColor = AppTheme.statusColor(issue.status.name);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (issue.imageUrls.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: issue.imageUrls.length,
                          itemBuilder: (_, i) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(issue.imageUrls[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(issue.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(issue.category.categoryEmoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text(issue.category.categoryLabel,
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
                    const Text('Description / వివరణ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(issue.description,
                        style: const TextStyle(fontSize: 14, height: 1.6)),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${issue.latitude},${issue.longitude}',
                        );
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A56DB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('View on Map 📍',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Reported by: ${issue.reporterName}',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFFF6B35).withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.update_rounded,
                                  color: Color(0xFFFF6B35)),
                              SizedBox(width: 8),
                              Text('Update Status / స్థితి మార్చండి',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Current: ${issue.statusLabel}',
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),

                          // ✅ FIX: All buttons now call _updateStatus() which properly awaits
                          _StatusBtn(
                            label: '🔴 Open',
                            telugu: 'తెరవబడింది',
                            color: AppTheme.danger,
                            selected: issue.status == IssueStatus.open,
                            isLoading: _isUpdating,
                            onTap: () => _updateStatus(
                                IssueStatus.open, 'Open', AppTheme.danger),
                          ),
                          const SizedBox(height: 8),
                          _StatusBtn(
                            label: '🟡 In Progress',
                            telugu: 'పురోగతిలో ఉంది',
                            color: AppTheme.warning,
                            selected: issue.status == IssueStatus.inProgress,
                            isLoading: _isUpdating,
                            onTap: () => _updateStatus(IssueStatus.inProgress,
                                'In Progress', AppTheme.warning),
                          ),
                          const SizedBox(height: 8),
                          _StatusBtn(
                            label: '🟢 Resolved',
                            telugu: 'పరిష్కరించబడింది',
                            color: AppTheme.success,
                            selected: issue.status == IssueStatus.resolved,
                            isLoading: _isUpdating,
                            onTap: () => _updateStatus(
                                IssueStatus.resolved, 'Resolved ✅', AppTheme.success),
                          ),
                          const SizedBox(height: 8),
                          _StatusBtn(
                            label: '⚫ Closed',
                            telugu: 'మూసివేయబడింది',
                            color: Colors.grey,
                            selected: issue.status == IssueStatus.closed,
                            isLoading: _isUpdating,
                            onTap: () => _updateStatus(
                                IssueStatus.closed, 'Closed', Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // ✅ NEW: Loading overlay while update is in progress
              if (_isUpdating)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ✅ UPDATED: Added isLoading param to disable buttons during update
class _StatusBtn extends StatelessWidget {
  final String label, telugu;
  final Color color;
  final bool selected;
  final bool isLoading;
  final VoidCallback onTap;

  const _StatusBtn({
    required this.label,
    required this.telugu,
    required this.color,
    required this.selected,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // ✅ Disabled while loading
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isLoading
              ? color.withOpacity(0.05)
              : selected
                  ? color
                  : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? color : color.withOpacity(0.3),
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: selected ? Colors.white : color)),
                  Text(telugu,
                      style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? Colors.white70
                              : color.withOpacity(0.7))),
                ],
              ),
            ),
            if (selected && !isLoading)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, emoji;
  final Color color;
  const _StatCard(this.label, this.value, this.emoji, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(color: color, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _AdminFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _AdminFilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? color : color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      ),
    );
  }
}