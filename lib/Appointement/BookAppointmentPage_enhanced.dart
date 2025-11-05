import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';

class BookAppointmentPage extends StatefulWidget {
  final Dio dio;
  final int patientId;
  final String patientName;
  final String patientContactNo;

  const BookAppointmentPage({
    super.key,
    required this.dio,
    required this.patientId,
    required this.patientName,
    required this.patientContactNo,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<dynamic> clinics = [];
  List<dynamic> patientReports = [];
  bool isLoading = true;
  bool isLoadingReports = false;
  dynamic selectedClinic;
  dynamic selectedReport;
  DateTime? selectedDate;
  final TextEditingController _medicalRequirementController =
      TextEditingController();
  final TextEditingController _reportUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchClinics();
    await fetchPatientReports();
  }

  Future<void> fetchClinics() async {
    try {
      final response = await widget.dio.get(
        'http://10.0.2.2:8080/api/clinic/auth/all',
      );

      if (response.statusCode == 200) {
        setState(() {
          clinics = response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load clinics: $e');
    }
  }

  Future<void> fetchPatientReports() async {
    setState(() {
      isLoadingReports = true;
    });

    try {
      final response = await widget.dio.get(
        'http://10.0.2.2:8080/api/patient/reports/patient/${widget.patientId}',
      );

      if (response.statusCode == 200) {
        setState(() {
          patientReports = response.data;
          isLoadingReports = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingReports = false;
      });
    }
  }

  Future<void> bookAppointment() async {
    if (selectedClinic == null || selectedDate == null) {
      _showErrorDialog('Please select a clinic and date');
      return;
    }

    try {
      final appointmentData = {
        "patientId": widget.patientId,
        "clinicId": selectedClinic['id'],
        "appointmentDate": DateFormat('yyyy-MM-dd').format(selectedDate!),
        "medicalRequirement": _medicalRequirementController.text,
        "reportUrl": selectedReport?['reportUrl'] ?? _reportUrlController.text,
      };

      final response = await widget.dio.post(
        'http://10.0.2.2:8080/api/clinic/appointment/create',
        data: appointmentData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog('Appointment booked successfully!');
      }
    } catch (e) {
      _showErrorDialog('Failed to book appointment: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.warning_2, color: AppTheme.error),
            const Gap(8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.tick_circle, color: AppTheme.success),
            const Gap(8),
            const Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.health,
                size: 20,
              ),
            ),
            const Gap(8),
            const Text('V_Docs'),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Book',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.white,
                  fontSize: 12,
                ),
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
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                  const Gap(16),
                  Text(
                    'Loading clinics...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    _buildHeader(),
                    const Gap(24),
                    
                    // Select Clinic Section
                    _buildSectionCard(
                      title: 'Select Clinic',
                      icon: Iconsax.hospital,
                      child: _buildClinicSelection(),
                    ),
                    const Gap(16),
                    
                    // Select Date Section
                    _buildSectionCard(
                      title: 'Appointment Date',
                      icon: Iconsax.calendar,
                      child: _buildDateSelection(),
                    ),
                    const Gap(16),
                    
                    // Medical Requirement Section
                    _buildSectionCard(
                      title: 'Medical Requirement',
                      icon: Iconsax.health,
                      child: _buildMedicalRequirement(),
                    ),
                    const Gap(16),
                    
                    // Report Selection Section
                    _buildSectionCard(
                      title: 'Attach Report (Optional)',
                      icon: Iconsax.document,
                      child: _buildReportSelection(),
                    ),
                    const Gap(32),
                    
                    // Book Button
                    _buildBookButton(),
                    const Gap(24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.calendar_add,
              size: 48,
              color: AppTheme.white,
            ),
          ),
          const Gap(16),
          Text(
            'Schedule Your Appointment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            'Book a consultation with our expert doctors',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              ),
              const Gap(12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }

  Widget _buildClinicSelection() {
    if (clinics.isEmpty) {
      return const Center(child: Text('No clinics available'));
    }

    return Column(
      children: clinics.map((clinic) {
        final isSelected = selectedClinic == clinic;
        return GestureDetector(
          onTap: () => setState(() => selectedClinic = clinic),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryBlue.withOpacity(0.1) 
                  : AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryBlue 
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryBlue 
                        : AppTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.hospital,
                    color: isSelected ? AppTheme.white : AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic['clinicName'] ?? 'Unknown Clinic',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primaryBlue : null,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        clinic['address'] ?? 'No address',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Iconsax.tick_circle5,
                    color: AppTheme.primaryBlue,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppTheme.primaryBlue,
                  onPrimary: AppTheme.white,
                  onSurface: AppTheme.textDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedDate != null 
              ? AppTheme.primaryBlue.withOpacity(0.1) 
              : AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedDate != null 
                ? AppTheme.primaryBlue 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar_1,
              color: selectedDate != null 
                  ? AppTheme.primaryBlue 
                  : AppTheme.textLight,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!)
                    : 'Select appointment date',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selectedDate != null 
                      ? AppTheme.primaryBlue 
                      : AppTheme.textLight,
                  fontWeight: selectedDate != null 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: AppTheme.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRequirement() {
    return TextField(
      controller: _medicalRequirementController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Describe your medical concern or symptoms...',
        filled: true,
        fillColor: AppTheme.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildReportSelection() {
    return Column(
      children: [
        if (isLoadingReports)
          const CircularProgressIndicator()
        else if (patientReports.isEmpty)
          Text(
            'No previous reports available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          )
        else
          Column(
            children: patientReports.map((report) {
              final isSelected = selectedReport == report;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedReport = isSelected ? null : report;
                  if (selectedReport != null) {
                    _reportUrlController.clear();
                  }
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.success.withOpacity(0.1) 
                        : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.success 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.document_text,
                        color: isSelected ? AppTheme.success : AppTheme.textLight,
                        size: 20,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          'Report #${report['id']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Iconsax.tick_circle5,
                          color: AppTheme.success,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const Gap(12),
        const Divider(),
        const Gap(12),
        TextField(
          controller: _reportUrlController,
          enabled: selectedReport == null,
          decoration: InputDecoration(
            hintText: 'Or paste report URL here...',
            prefixIcon: const Icon(Iconsax.link),
            filled: true,
            fillColor: selectedReport == null 
                ? AppTheme.lightGrey 
                : AppTheme.lightGrey.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return ElevatedButton(
      onPressed: bookAppointment,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.tick_circle),
          const Gap(8),
          Text(
            'Book Appointment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _medicalRequirementController.dispose();
    _reportUrlController.dispose();
    super.dispose();
  }
}
