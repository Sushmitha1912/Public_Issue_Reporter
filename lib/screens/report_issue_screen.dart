import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _issueService = IssueService();
  final _authService = AuthService();

  IssueCategory _category = IssueCategory.roadDamage;
  IssuePriority _priority = IssuePriority.medium;
  final List<XFile> _images = [];
  double? _lat, _lng;
  bool _loading = false;
  bool _gettingLocation = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos allowed')));
      return;
    }
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _images.add(picked));
  }

  Future<void> _pickFromGallery() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos allowed')));
      return;
    }
    final picked = await ImagePicker().pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      final remaining = 3 - _images.length;
      setState(() => _images.addAll(picked.take(remaining)));
    }
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Location services disabled');
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied)
          throw Exception('Permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _addressCtrl.text =
            'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Location error: $e')));
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please capture your location first!'),
          backgroundColor: AppTheme.danger));
      return;
    }
    setState(() => _loading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Not logged in');
      final profile = await _authService.getUserProfile(user.uid);
      await _issueService.createIssue(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        priority: _priority,
        latitude: _lat!,
        longitude: _lng!,
        address: _addressCtrl.text.trim(),
        images: _images,
        userId: user.uid,
        userName: profile?['name'] ?? user.displayName ?? 'Anonymous',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Issue submitted! 🎉'),
            backgroundColor: AppTheme.success));
        _reset();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _addressCtrl.clear();
    setState(() {
      _category = IssueCategory.roadDamage;
      _priority = IssuePriority.medium;
      _images.clear();
      _lat = null;
      _lng = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Report Issue',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            Text('సమస్య నివేదించండి',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      Icon(Icons.photo_library_outlined,
                          color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text('Add Photos / ఫోటోలు జోడించండి',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Max 3 photos',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickFromCamera,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFFFF6B35)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 28),
                                SizedBox(height: 4),
                                Text('Camera',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                Text('కెమెరా',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickFromGallery,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.photo_library_rounded,
                                    color: Colors.white, size: 28),
                                SizedBox(height: 4),
                                Text('Gallery',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                Text('గ్యాలరీ',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (_, i) => Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _images[i].path,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _images.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            _Label('Issue Title / సమస్య శీర్షిక'),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  hintText: 'e.g. Broken road on Main Street'),
              maxLength: 100,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),

            // Category
            _Label('Category / వర్గం'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: IssueCategory.values.length,
              itemBuilder: (_, i) {
                final cat = IssueCategory.values[i];
                final sel = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                          width: sel ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.categoryEmoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 3),
                        Text(cat.categoryLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? Colors.white
                                    : Colors.grey.shade700)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Priority
            _Label('Priority / ప్రాధాన్యత'),
            Row(
              children: IssuePriority.values.map((p) {
                final sel = _priority == p;
                final color = AppTheme.priorityColor(p.name);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? color : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        p.name[0].toUpperCase() + p.name.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : color),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Description
            _Label('Description / వివరణ'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail...'),
              validator: (v) => v == null || v.trim().length < 10
                  ? 'At least 10 characters'
                  : null,
            ),
            const SizedBox(height: 12),

            // Location
            _Label('Location / లొకేషన్'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Address or tap GPS button',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter location' : null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _gettingLocation ? null : _getLocation,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14)),
                  child: _gettingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
            if (_lat != null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 14, color: AppTheme.success),
                    SizedBox(width: 4),
                    Text('GPS captured ✅',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.success)),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded),
                        SizedBox(width: 8),
                        Text('Submit Report / సమర్పించండి',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151))),
      );
}