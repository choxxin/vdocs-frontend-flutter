import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_widgets.dart';

class ReportUploadPage extends StatefulWidget {
  @override
  _ReportUploadPageState createState() => _ReportUploadPageState();
}

class _ReportUploadPageState extends State<ReportUploadPage> {
  late Dio _dio;
  late int _patientId;
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _message;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments passed from the previous page
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _dio = args['dio'] as Dio;
    _patientId = args['patientId'] as int;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _message = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _message = "Please select a file first.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ),
        "patientId": _patientId,
      });

      final response = await _dio.post(
        "http://10.0.2.2:8080/api/patient/reports/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = "Report uploaded successfully!";
          _selectedFile = null;
        });
      } else {
        setState(() {
          _message =
              "Failed to upload report. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error uploading report: $e";
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
            const SizedBox(width: 10),
            const Text(
              "V_Docs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Upload",
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
                        Iconsax.document_upload,
                        size: 48,
                        color: AppTheme.white,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      "Upload Medical Report",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      "Share your medical documents securely",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // File Selection Section
              Container(
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.document,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          "Select Document",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Text(
                      "Supported formats: PDF, JPG, PNG (Max 10MB)",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Gap(24),

                    if (_selectedFile == null)
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.primaryBlue.withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Iconsax.folder_add,
                                  size: 32,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const Gap(16),
                              Text(
                                "Tap to select file",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                "or drag and drop here",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getFileIcon(_selectedFile!.extension),
                                color: AppTheme.success,
                                size: 24,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile!.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatFileSize(_selectedFile!.size),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _message = null;
                                });
                              },
                              icon: const Icon(
                                Iconsax.close_circle,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(32),

              // Upload Button
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                      ),
                      const Gap(16),
                      Text(
                        "Uploading your report...",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _selectedFile != null ? _uploadFile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFile != null
                        ? AppTheme.primaryBlue
                        : AppTheme.textLight,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _selectedFile != null ? 8 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.document_upload),
                      const Gap(8),
                      Text(
                        "Upload Report",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Message Display
              if (_message != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _message!.contains("success")
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _message!.contains("success")
                          ? AppTheme.success.withOpacity(0.3)
                          : AppTheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _message!.contains("success")
                            ? Iconsax.tick_circle
                            : Iconsax.warning_2,
                        color: _message!.contains("success")
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          _message!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _message!.contains("success")
                                ? AppTheme.success
                                : AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Iconsax.document_text;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Iconsax.gallery;
      default:
        return Iconsax.document;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
