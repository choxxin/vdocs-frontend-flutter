import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/app_theme.dart';
import '../services/terms_service.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _isAgreed = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  Future<void> _acceptTerms() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions to continue'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await TermsService.acceptTerms();

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to the main login page
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save acceptance. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.shield_tick,
                          color: AppTheme.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terms and Conditions',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'VDocs Patient App',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          color: AppTheme.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please read carefully before using the app',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Terms Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'PLEASE READ THESE TERMS AND CONDITIONS CAREFULLY BEFORE USING THE VDOCS PATIENT APP.',
                        '',
                        isImportant: true,
                      ),
                      _buildSection(
                        '1. Acceptance of Terms',
                        'Welcome to VDocs Patient App ("VDocs", "we", "us", or "our"), developed and operated by VD NextGen Digital Private Limited. By downloading, installing, accessing, or using our mobile application and related services (the "Services"), you ("user", "you") signify that you have read, understood, and agree to be bound by these Terms and Conditions ("Terms") and our Privacy Policy. If you do not agree to these Terms, you must not access or use the Services.',
                      ),
                      _buildSection(
                        '2. Eligibility',
                        'You must be at least 18 years of age to use the Services. By using the Services, you represent and warrant that you are at least 18 years old. If you are under 18, you may use the Services only under the supervision of a parent or legal guardian who agrees to be bound by these Terms.',
                      ),
                      _buildSection(
                        '3. Account Registration and Security',
                        'To access certain features, you must register for an account using your mobile number (via OTP verification) or email address. You agree to provide accurate and complete information and to keep it updated. You are solely responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. You must notify us immediately at contact@vdocs.in of any unauthorized use of your account.',
                      ),
                      _buildSection(
                        '4. Description of Services',
                        'VDocs provides a secure digital platform that allows you to:\n\n• Upload, store, categorize, and manage your healthcare reports, prescriptions, and medical files.\n• Receive reports automatically from VDocs-partnered clinics and laboratories.\n• Book appointments with onboarded clinics.\n• View AI-generated insights and organization of your health data.\n\nYou acknowledge and agree that VDocs is not a healthcare provider. The Services are for record-keeping, organization, and informational purposes only. They do not constitute medical advice, diagnosis, or treatment. Always seek the advice of a qualified healthcare professional with any questions you may have regarding a medical condition.',
                        isImportant: true,
                      ),
                      _buildSection(
                        '5. User Responsibilities and Acceptable Use',
                        'You agree not to use the Services to:\n\n• Upload any false, misleading, malicious, or unauthorized medical data.\n• Impersonate any person or entity or use another person\'s medical information without their explicit consent.\n• Engage in any fraudulent, abusive, or unlawful activity.\n• Attempt to reverse engineer, decompile, hack, disable, interfere with, or disrupt the integrity or performance of the Services, including our systems and databases.\n\nWe reserve the right to suspend or terminate your account immediately if we determine, in our sole discretion, that you have violated these Terms.',
                      ),
                      _buildSection(
                        '6. Data Ownership and License',
                        'You retain all ownership rights to the medical data and information you upload to the Services ("Your Data"). By uploading Your Data, you grant VDocs a limited, non-exclusive, royalty-free, and worldwide license to host, store, process, and display Your Data solely for the purpose of providing, maintaining, and improving the Services for you.',
                      ),
                      _buildSection(
                        '7. Data Security and Privacy',
                        'We implement ABDM-aligned and industry-standard technical and organizational security measures designed to protect Your Data. We do not sell your health data. Our data collection, storage, and retention practices are described in detail in our Privacy Policy, which is incorporated into these Terms by reference.\n\nWhile we strive to protect your information, no electronic transmission or storage method is 100% secure. You acknowledge and accept this inherent risk by using our Services.',
                      ),
                      _buildSection(
                        '8. Third-Party Services',
                        'The Services may integrate with or link to third-party services, such as cloud infrastructure providers, email delivery services, and analytics tools. Your use of such third-party services may be subject to their own terms and policies. We are not responsible for the practices of these third parties.',
                      ),
                      _buildSection(
                        '9. AI-Generated Insights Disclaimer',
                        'The AI-generated insights, categorizations, and summaries provided by the Services are automated and for your informational convenience only. They are based on algorithmic processing of your data and are not reviewed by a healthcare professional. VDocs does not guarantee the accuracy, completeness, or clinical utility of these insights. They are not a substitute for professional medical judgment.',
                        isImportant: true,
                      ),
                      _buildSection(
                        '10. Service Availability and Disclaimer',
                        'We strive to provide a reliable service but cannot guarantee uninterrupted access. The Services are provided on an "AS IS" and "AS AVAILABLE" basis. We disclaim all warranties, express or implied, including implied warranties of merchantability and fitness for a particular purpose. We are not liable for any service interruptions, delays, or data loss resulting from maintenance, updates, technical failures, or any events beyond our reasonable control (force majeure).',
                      ),
                      _buildSection(
                        '11. Limitation of Liability',
                        'To the fullest extent permitted by applicable law, VD NextGen Digital Private Limited, its directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, or other intangible losses, resulting from:\n\n• Your access to or use of or inability to access or use the Services.\n• Any conduct or content of any third party on the Services.\n• Any unauthorized access, use, or alteration of Your Data.',
                      ),
                      _buildSection(
                        '12. Account Deletion',
                        'You may request the deletion of your account and all associated data at any time by sending an email to contact@vdocs.in. We will process your request and permanently delete your data from our active systems within thirty (30) business days of verification.',
                      ),
                      _buildSection(
                        '13. Modifications to Terms',
                        'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days\' notice prior to any new terms taking effect, via email or an in-app notification. What constitutes a material change will be determined at our sole discretion. By continuing to access or use our Services after those revisions become effective, you agree to be bound by the revised Terms.',
                      ),
                      _buildSection(
                        '14. Governing Law and Dispute Resolution',
                        'These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions. Any dispute arising out of or relating to these Terms or your use of the Services shall be subject to the exclusive jurisdiction of the courts located in India.',
                      ),
                      _buildSection(
                        '15. Contact Us',
                        'If you have any questions about these Terms, please contact us at:\n\nEmail: contact@vdocs.in',
                      ),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Last Updated: October 28, 2025',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Agreement Checkbox and Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Scroll hint
                  if (!_hasScrolledToBottom)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.arrow_down,
                            color: AppTheme.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please scroll through all terms',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Checkbox
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAgreed = !_isAgreed;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAgreed
                              ? AppTheme.primaryBlue
                              : AppTheme.textLight.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _isAgreed
                                  ? AppTheme.primaryBlue
                                  : AppTheme.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _isAgreed
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textLight,
                                width: 2,
                              ),
                            ),
                            child: _isAgreed
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppTheme.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                    ),
                                children: [
                                  const TextSpan(
                                    text: 'I agree to the ',
                                  ),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' and acknowledge the ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _acceptTerms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAgreed
                            ? AppTheme.primaryBlue
                            : AppTheme.textLight.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SpinKitThreeBounce(
                              color: AppTheme.white,
                              size: 20,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.tick_circle),
                                const SizedBox(width: 8),
                                Text(
                                  'Accept & Continue',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isImportant ? AppTheme.error : AppTheme.textDark,
                ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark,
                    height: 1.6,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.textLight.withOpacity(0.1),
            AppTheme.textLight.withOpacity(0.3),
            AppTheme.textLight.withOpacity(0.1),
          ],
        ),
      ),
    );
  }
}
