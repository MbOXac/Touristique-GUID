import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/country_picker.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _birthday;
  String? _gender;
  Country? _selectedCountry;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _email;
  String? _photoURL;

  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _email = user.email;
      _photoURL = user.photoURL;
    });

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? user.displayName ?? '';
      _phoneController.text = data['phone'] ?? '';
      _gender = data['gender'];
      _selectedCountry = CountryPicker.findByName(data['country']);
      if (data['birthday'] != null) {
        _birthday = (data['birthday'] as Timestamp).toDate();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange,
              onPrimary: Colors.white,
              onSurface: AppTheme.deepBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  Future<void> _pickCountry() async {
    final country = await CountryPicker.show(
      context,
      selectedCountry: _selectedCountry?.name,
    );
    if (country != null) {
      setState(() => _selectedCountry = country);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country': _selectedCountry?.name,
        'countryCode': _selectedCountry?.code,
        'countryFlag': _selectedCountry?.flag,
        'gender': _gender,
        'birthday': _birthday != null ? Timestamp.fromDate(_birthday!) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully'),
          backgroundColor: AppTheme.oasisGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $_email'),
          backgroundColor: AppTheme.oasisGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.sandBeige,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryOrange,
                            width: 3,
                          ),
                          image: _photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(_photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoURL == null
                            ? const Icon(Icons.person, size: 60, color: AppTheme.earthBrown)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Personal Information'),
                    const SizedBox(height: 12),

                    // Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email (read-only)
                    _buildReadOnlyField(
                      label: 'Email',
                      value: _email ?? '',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Birthday
                    InkWell(
                      onTap: _pickBirthday,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined, color: AppTheme.primaryOrange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Birthday',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  _birthday != null ? _formatDate(_birthday!) : 'Select your birthday',
                                  style: const TextStyle(fontSize: 16, color: AppTheme.deepBlue),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: const Icon(Icons.wc_outlined, color: AppTheme.primaryOrange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _genders
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // 🌍 COUNTRY PICKER WITH FLAGS
                    InkWell(
                      onTap: _pickCountry,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flag_outlined, color: AppTheme.primaryOrange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Country',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Row(
                                  children: [
                                    if (_selectedCountry != null) ...[
                                      Text(_selectedCountry!.flag,
                                          style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      _selectedCountry?.name ?? 'Select your country',
                                      style: const TextStyle(fontSize: 16, color: AppTheme.deepBlue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Security'),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock_outline, color: AppTheme.primaryOrange),
                        title: const Text('Change Password'),
                        subtitle: const Text('Reset link will be sent to your email'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _changePassword,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveChanges,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.deepBlue,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.lock_outline, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}