import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ClinicRegisterPage extends StatefulWidget {
  @override
  _ClinicRegisterPageState createState() => _ClinicRegisterPageState();
}

class _ClinicRegisterPageState extends State<ClinicRegisterPage> {
  final _clinicNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final Dio _dio;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio();
    if (kIsWeb) {
      _dio.options.extra['withCredentials'] = true;
    }
  }

  Future<void> _register() async {
    if (_clinicNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all required fields.";
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
      final response = await _dio.post(
        "http://10.0.2.2:8080/api/clinic/auth/register",
        data: {
          "name": _clinicNameController.text,
          "email": _emailController.text,
          "contactNo": _phoneController.text,
          "address": _addressController.text,
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _successMessage =
              "Registration successful! Please login with your credentials.";
        });

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = "Registration failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "Clinic Registration",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 141, 130, 130),
        elevation: 2,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital_outlined,
                  size: 80, color: Colors.blue[400]),
              SizedBox(height: 16),
              Text(
                "Register Your Clinic",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),

              _buildInputField(
                  controller: _clinicNameController,
                  label: "Clinic Name *",
                  icon: Icons.business_outlined),
              SizedBox(height: 18),

              _buildInputField(
                  controller: _emailController,
                  label: "Email *",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 18),

              _buildInputField(
                  controller: _phoneController,
                  label: "Phone Number *",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              SizedBox(height: 18),

              _buildInputField(
                  controller: _addressController,
                  label: "Address *",
                  icon: Icons.location_on_outlined,
                  maxLines: 2),
              SizedBox(height: 18),

              _buildInputField(
                  controller: _passwordController,
                  label: "Password *",
                  icon: Icons.lock_outline,
                  obscureText: true),
              SizedBox(height: 18),

              _buildInputField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password *",
                  icon: Icons.lock_outline,
                  obscureText: true),
              SizedBox(height: 28),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Register Clinic",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 22),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 16,
                  ),
                ),
              ),

              if (_successMessage != null) ...[
                SizedBox(height: 20),
                _buildMessageCard(
                    icon: Icons.check_circle_outline,
                    text: _successMessage!,
                    color: Colors.green),
              ],

              if (_errorMessage != null) ...[
                SizedBox(height: 20),
                _buildMessageCard(
                    icon: Icons.error_outline,
                    text: _errorMessage!,
                    color: Colors.red),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.blue[400]),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Card(
      color: Colors.grey[850],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clinicNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
