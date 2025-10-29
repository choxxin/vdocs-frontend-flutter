import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';

class PatientRegisterPage extends StatefulWidget {
  @override
  _PatientRegisterPageState createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final Dio _dio;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;
  String? _selectedGender;
  List<String> _allergies = [];
  final _allergyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio();
    if (kIsWeb) _dio.options.extra['withCredentials'] = true;
  }

  void _addAllergy() {
    if (_allergyController.text.trim().isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text.trim());
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
  }

  Future<void> _register() async {
    // Validate only required fields
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all required fields (marked with *).";
        _successMessage = null;
      });
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Prepare request data - only include non-empty optional fields
      final Map<String, dynamic> requestData = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "age": int.parse(_ageController.text),
        "phoneNumber": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
      };

      // Add optional fields only if they have values
      if (_selectedGender != null) {
        requestData["gender"] = _selectedGender;
      }
      if (_addressController.text.trim().isNotEmpty) {
        requestData["address"] = _addressController.text.trim();
      }
      if (_medicalHistoryController.text.trim().isNotEmpty) {
        requestData["medicalHistory"] = _medicalHistoryController.text.trim();
      }
      if (_allergies.isNotEmpty) {
        requestData["allergies"] = _allergies.map((allergy) => {"allergyName": allergy}).toList();
      }

      final response = await _dio.post(
        "http://10.0.2.2:8080/api/patient/auth/register",
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _successMessage = "Registration successful! Redirecting to login...";
        });
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = "Registration failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString().contains('DioException') ? 'Network error. Please check your connection.' : e}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {bool isRequired = false}) {
    return InputDecoration(
      labelText: label + (isRequired ? " *" : ""),
      labelStyle: TextStyle(color: AppTheme.textLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
      ),
      prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
      filled: true,
      fillColor: AppTheme.lightGrey,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.error),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.health, size: 20),
            ),
            const Gap(10),
            const Text(
              "V_Docs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Iconsax.user_add,
                        size: 40,
                        color: AppTheme.white,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      "Create Patient Account",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      "Join V_Docs for better healthcare management",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // Form Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Required Fields Section
                    Text(
                      "Required Information",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const Gap(16),

                    // Name Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: _inputDecoration("First Name", Iconsax.user, isRequired: true),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: _inputDecoration("Last Name", Iconsax.user, isRequired: true),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),

                    // Age Field
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Age", Iconsax.calendar, isRequired: true),
                    ),
                    const Gap(16),

                    // Contact Fields
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Phone Number", Iconsax.call, isRequired: true),
                    ),
                    const Gap(16),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email", Iconsax.message, isRequired: true),
                    ),
                    const Gap(16),

                    // Password Fields
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Password", Iconsax.lock, isRequired: true),
                    ),
                    const Gap(16),

                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _inputDecoration("Confirm Password", Iconsax.lock, isRequired: true),
                    ),
                    const Gap(24),

                    // Optional Fields Section
                    const Divider(),
                    const Gap(16),
                    Text(
                      "Optional Information",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      "You can fill these later in your profile",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Gap(16),

                    // Gender Selection
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputDecoration("Gender", Iconsax.profile_2user),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                      },
                    ),
                    const Gap(16),

                    // Address Field
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: _inputDecoration("Address", Iconsax.location),
                    ),
                    const Gap(16),

                    // Medical History Field
                    TextField(
                      controller: _medicalHistoryController,
                      maxLines: 3,
                      decoration: _inputDecoration("Medical History", Iconsax.health),
                    ),
                    const Gap(16),

                    // Allergies Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.warning_2, color: AppTheme.primaryBlue, size: 20),
                            const Gap(8),
                            Text(
                              "Allergies",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Optional",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        
                        // Add Allergy Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _allergyController,
                                decoration: InputDecoration(
                                  hintText: "Enter allergy name (e.g., Penicillin, Dust)",
                                  filled: true,
                                  fillColor: AppTheme.lightGrey,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onSubmitted: (_) => _addAllergy(),
                              ),
                            ),
                            const Gap(8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Iconsax.add, color: AppTheme.white),
                                onPressed: _addAllergy,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        
                        // Display Added Allergies
                        if (_allergies.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.info_circle, color: AppTheme.textLight, size: 16),
                                const Gap(8),
                                Text(
                                  "No allergies added yet",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allergies.asMap().entries.map((entry) {
                              final index = entry.key;
                              final allergy = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Iconsax.warning_2, color: AppTheme.primaryBlue, size: 14),
                                    const Gap(4),
                                    Text(
                                      allergy,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Gap(4),
                                    GestureDetector(
                                      onTap: () => _removeAllergy(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Iconsax.close_circle,
                                          color: AppTheme.error,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                    const Gap(32),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: AppTheme.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.user_add),
                                  const Gap(8),
                                  Text(
                                    "Create Account",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const Gap(16),

                    // Login Link
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textLight,
                          ),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),

              // Success/Error Messages
              if (_successMessage != null) 
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.tick_circle, color: AppTheme.success),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null) 
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.warning_2, color: AppTheme.error),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _allergyController.dispose();
    super.dispose();
  }
}
