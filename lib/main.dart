import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/terms_service.dart';
import 'core/screens/terms_and_conditions_page.dart';
import 'login_page.dart';
import 'clinic/clinic_login_page.dart';
import 'clinic/clinic_homepage.dart';
import 'patient/patient_login_page.dart';
import 'patient/patient_homepage.dart';
import 'patient/report_upload_page.dart';
import 'patient/patient_register.dart';
import 'clinic/clinic_register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VDocs - Medical Services',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/terms': (context) => const TermsAndConditionsPage(),
        '/login': (context) => LoginPage(),
        '/clinic-login': (context) => ClinicLoginPage(),
        '/clinic-home': (context) => ClinicHomePage(),
        '/patient-login': (context) => PatientLoginPage(),
        '/patient-home': (context) => PatientHomePage(),
        '/uploadReport': (context) => ReportUploadPage(),
        '/patient-register': (context) => PatientRegisterPage(),
        '/clinic-register': (context) => ClinicRegisterPage(),
      },
    );
  }
}

/// Splash screen to check T&C acceptance
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTermsAcceptance();
  }

  Future<void> _checkTermsAcceptance() async {
    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 500));
    
    final hasAccepted = await TermsService.hasAcceptedTerms();
    
    if (!mounted) return;
    
    if (hasAccepted) {
      // User has accepted T&C, go to login page
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // User needs to accept T&C
      Navigator.of(context).pushReplacementNamed('/terms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital,
                  size: 64,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'VDocs',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Digital Health Companion',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: AppTheme.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
