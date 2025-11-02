import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:iconsax/iconsax.dart';

class PatientProfilePage extends StatefulWidget {
  final Dio dio;
  final Map<String, dynamic> patientData;

  const PatientProfilePage({
    Key? key,
    required this.dio,
    required this.patientData,
  }) : super(key: key);

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool _isEditing = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _medicalHistoryController;
  late TextEditingController _currentMedController;
  List<TextEditingController> _allergyControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.patientData['firstName']);
    _lastNameController = TextEditingController(text: widget.patientData['lastName']);
    _phoneController = TextEditingController(text: widget.patientData['phoneNumber']);
    _addressController = TextEditingController(text: widget.patientData['address']);
    _medicalHistoryController = TextEditingController(text: widget.patientData['medicalHistory'] ?? '');
    _currentMedController = TextEditingController(text: widget.patientData['currentMedications'] ?? '');

    // initialize allergy controllers from patientData (if available)
    _allergyControllers.forEach((c) => c.dispose());
    _allergyControllers = [];
    final allergies = widget.patientData['allergies'];
    if (allergies is List) {
      for (var a in allergies) {
        final name = (a is Map && a['allergyName'] != null) ? a['allergyName'].toString() : a.toString();
        _allergyControllers.add(TextEditingController(text: name));
      }
    }
    // Ensure at least one controller to allow adding
    if (_allergyControllers.isEmpty) {
      _allergyControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF2E86C1),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Iconsax.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF2E86C1).withOpacity(0.1),
                        child: const Icon(
                          Iconsax.woman,
                          size: 50,
                          color: Color(0xFF2E86C1),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E86C1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.camera,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.patientData['firstName']} ${widget.patientData['lastName']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.patientData['email'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E86C1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Patient ID: ${widget.patientData['id']}',
                      style: const TextStyle(
                        color: Color(0xFF2E86C1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoField(
                          'First Name',
                          _firstNameController,
                          Iconsax.user,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoField(
                          'Last Name',
                          _lastNameController,
                          Iconsax.user,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          'Age',
                          '${widget.patientData['age']} years',
                          Iconsax.calendar,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          'Gender',
                          widget.patientData['gender'],
                          Iconsax.profile_2user,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    'Phone Number',
                    _phoneController,
                    Iconsax.call,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildReadOnlyField(
                    'Email',
                    widget.patientData['email'],
                    Iconsax.sms,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    'Address',
                    _addressController,
                    Iconsax.location,
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    'Medical History',
                    _medicalHistoryController,
                    Iconsax.health,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Current Medications
                  _buildInfoField(
                    'Current Medications',
                    _currentMedController,
                    Iconsax.chart,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 16),

                  // Allergies
                  const Text(
                    'Allergies',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_isEditing)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allergyControllers
                          .where((c) => c.text.trim().isNotEmpty)
                          .map((c) => Chip(
                                label: Text(c.text),
                                backgroundColor: const Color(0xFFF8D7DA),
                              ))
                          .toList(),
                    )
                  else
                    Column(
                      children: [
                        for (var i = 0; i < _allergyControllers.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _allergyControllers[i],
                                    enabled: _isEditing,
                                    decoration: InputDecoration(
                                      hintText: 'Allergy name',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FA),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _allergyControllers[i].dispose();
                                      _allergyControllers.removeAt(i);
                                      if (_allergyControllers.isEmpty) {
                                        _allergyControllers.add(TextEditingController());
                                      }
                                    });
                                  },
                                  icon: const Icon(Iconsax.close_circle),
                                ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _allergyControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Iconsax.add),
                            label: const Text('Add Allergy'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _initializeControllers();
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Iconsax.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Iconsax.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC3545),
                        side: const BorderSide(color: Color(0xFFDC3545)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: !_isEditing,
            fillColor: _isEditing ? null : const Color(0xFFF8F9FA),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF6C757D),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    // gather payload
    final payload = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'age': widget.patientData['age'],
      'gender': widget.patientData['gender'],
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'medicalHistory': _medicalHistoryController.text.trim(),
      'currentMedications': _currentMedController.text.trim(),
      'allergies': _allergyControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => {'allergyName': s})
          .toList(),
    };

    // perform API call
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    widget.dio
        .post('/api/patient/auth/update', data: payload)
        .then((response) {
      Navigator.pop(context); // close progress
      // merge response or assume success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF28A745),
        ),
      );
      // update local patientData map so UI reflects saved values
      setState(() {
        widget.patientData['firstName'] = payload['firstName'];
        widget.patientData['lastName'] = payload['lastName'];
        widget.patientData['phoneNumber'] = payload['phoneNumber'];
        widget.patientData['address'] = payload['address'];
        widget.patientData['medicalHistory'] = payload['medicalHistory'];
        widget.patientData['currentMedications'] = payload['currentMedications'];
        widget.patientData['allergies'] = payload['allergies'];
        _isEditing = false;
      });
    }).catchError((error) {
      Navigator.pop(context); // close progress
    final String message = (error is DioError && error.response?.data != null)
      ? error.response?.data.toString() ?? 'Failed to update profile. Please try again.'
      : 'Failed to update profile. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.logout,
              color: const Color(0xFFDC3545),
            ),
            const SizedBox(width: 8),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _currentMedController.dispose();
    for (var c in _allergyControllers) {
      c.dispose();
    }
    super.dispose();
  }
}