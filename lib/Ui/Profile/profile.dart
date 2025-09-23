import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Ravikant Saini');
  final _mobileController = TextEditingController(text: '6397199758');
  final _emailController = TextEditingController(text: 'ravikantsaini03061996@gmail.com');
  final _dobController = TextEditingController(text: '03/06/1996');
  final _anniversaryController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _anniversaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: const Text(
          'Your Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(colorScheme),
            const SizedBox(height: 24),
            _buildFormFields(colorScheme),
            const SizedBox(height: 32),
            _buildUpdateButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // The outer gold border
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade300,
                Colors.yellow.shade800,
              ],
            ),
          ),
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundColor: colorScheme.surface,
            radius: 56,
            child: Text(
              'R',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        // Edit icon
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.surface,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.edit,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              labelText: 'Name',
              icon: const Icon(Icons.person_outline),
              suffix: const Icon(Icons.close, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _mobileController,
              labelText: 'Mobile',
              icon: const Icon(Icons.phone_iphone),
              suffix: TextButton(
                onPressed: () {},
                child: const Text('CHANGE'),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: const Icon(Icons.email_outlined),
              suffix: TextButton(
                onPressed: () {},
                child: const Text('CHANGE'),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dobController,
              labelText: 'Date of birth',
              icon: const Icon(Icons.calendar_today_outlined),
              suffix: const Icon(Icons.close, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _anniversaryController,
              labelText: 'Anniversary',
              icon: const Icon(Icons.cake_outlined),
            ),
            const SizedBox(height: 16),
            _buildGenderDropdown(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required Icon icon,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      readOnly: true, // Fields are read-only in this design
    );
  }

  Widget _buildGenderDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: _selectedGender,
      items: ['Male', 'Female', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      hint: const Text('Select Gender'),
    );
  }

  Widget _buildUpdateButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle update profile action
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: const Text(
          'Update profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}