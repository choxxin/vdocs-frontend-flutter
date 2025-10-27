import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'dart:async';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_widgets.dart';
import './report_upload_page.dart';
import '../Appointement/BookAppointmentPage.dart';
import './Report_history_page.dart';
import './patient_appointments.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late final Dio _dio;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  PageController _healthTipsController = PageController();
  int _currentTipIndex = 0;
  Timer? _carouselTimer;
  
  // Health tips data
  final List<Map<String, dynamic>> _healthTips = [
    {
      'title': 'Stay Hydrated',
      'subtitle': 'Drink 8 glasses of water daily',
      'icon': Iconsax.drop,
      'color': Colors.blue,
    },
    {
      'title': 'Exercise Daily',
      'subtitle': '30 minutes of physical activity',
      'icon': Iconsax.heart,
      'color': Colors.red,
    },
    {
      'title': 'Eat Healthy',
      'subtitle': 'Include fruits and vegetables',
      'icon': Iconsax.cake,
      'color': Colors.green,
    },
    {
      'title': 'Get Enough Sleep',
      'subtitle': '7-8 hours of quality sleep',
      'icon': Iconsax.moon,
      'color': Colors.purple,
    },
  ];
  
  // Nearby doctors dummy data
  final List<Map<String, dynamic>> _nearbyDoctors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'rating': 4.8,
      'distance': '0.5 km',
      'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
    },
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Neurologist',
      'rating': 4.9,
      'distance': '1.2 km',
      'image': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150',
    },
    {
      'name': 'Dr. Emily Davis',
      'specialty': 'Dermatologist',
      'rating': 4.7,
      'distance': '1.8 km',
      'image': 'https://images.unsplash.com/photo-1594824711323-8a9f67b35ed1?w=150',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDio();
      _startHealthTipsCarousel();
    });
  }
  
  @override
  void dispose() {
    _carouselTimer?.cancel();
    _healthTipsController.dispose();
    super.dispose();
  }
  
  void _startHealthTipsCarousel() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          _currentTipIndex = (_currentTipIndex + 1) % _healthTips.length;
          if (_healthTipsController.hasClients) {
            _healthTipsController.animateToPage(
              _currentTipIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  void _initializeDio() {
    // Get the Dio instance passed from login page
    final Dio? passedDio = ModalRoute.of(context)?.settings.arguments as Dio?;

    if (passedDio != null) {
      _dio = passedDio;
    } else {
      // Create a new Dio instance with web configuration
      _dio = Dio();
      if (kIsWeb) {
        _dio.options.extra['withCredentials'] = true;
      }
    }

    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _dio.get(
        "http://localhost:8080/api/patient/auth/me",
      );

      if (response.statusCode == 200) {
        setState(() {
          _patientData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch patient data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildHeader() {
    if (_patientData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showProfileDialog(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background
                        Container(
                          color: AppTheme.white,
                        ),
                        // Head (circle)
                        Positioned(
                          top: 12,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryBlue.withOpacity(0.7),
                            ),
                          ),
                        ),
                        // Shoulders (semi-circle)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 50,
                            height: 35,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.7),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withOpacity(0.8),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${_patientData!['firstName'] ?? ''} ${_patientData!['lastName'] ?? ''}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showProfileDialog(),
                    icon: const Icon(
                      Iconsax.profile_circle,
                      color: AppTheme.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showLogoutDialog(),
                    icon: const Icon(
                      Iconsax.logout,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: AppTheme.white,
                  size: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Your health journey starts here. Access all your medical services in one place.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Health Tips',
            subtitle: 'Daily wellness reminders',
          ),
          const Gap(8),
          Container(
            height: 120,
            child: PageView.builder(
              controller: _healthTipsController,
              itemCount: _healthTips.length,
              itemBuilder: (context, index) {
                final tip = _healthTips[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tip['color'].withOpacity(0.1),
                        tip['color'].withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: tip['color'].withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tip['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tip['icon'],
                          color: tip['color'],
                          size: 24,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tip['title'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tip['color'],
                              ),
                            ),
                            const Gap(4),
                            Text(
                              tip['subtitle'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyDoctors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Nearby Doctors',
            subtitle: 'Top-rated medical professionals near you',
          ),
          const Gap(8),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _nearbyDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _nearbyDoctors[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
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
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(
                            image: NetworkImage(doctor['image']),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name'],
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(4),
                            Text(
                              doctor['specialty'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.star1,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const Gap(4),
                                Text(
                                  '${doctor['rating']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Gap(8),
                                Icon(
                                  Iconsax.location,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const Gap(4),
                                Text(
                                  doctor['distance'],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Quick Overview',
            subtitle: 'Your health statistics at a glance',
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  child: SlideAnimation(
                    horizontalOffset: -50,
                    child: FadeInAnimation(
                      child: StatCard(
                        icon: Iconsax.calendar,
                        title: 'Appointments',
                        value: '3',
                        iconColor: AppTheme.info,
                        onTap: () => _navigateToAppointments(),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: AnimationConfiguration.staggeredList(
                  position: 1,
                  child: SlideAnimation(
                    horizontalOffset: 50,
                    child: FadeInAnimation(
                      child: StatCard(
                        icon: Iconsax.document,
                        title: 'Reports',
                        value: '8',
                        iconColor: AppTheme.success,
                        onTap: () => _navigateToReports(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Quick Actions',
            subtitle: 'Manage your health needs',
          ),
          const Gap(8),
          AnimationConfiguration.staggeredList(
            position: 0,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.calendar_add,
                  title: 'Book Appointment',
                  subtitle: 'Schedule your next consultation',
                  iconColor: AppTheme.primaryBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookAppointmentPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Gap(12),
          AnimationConfiguration.staggeredList(
            position: 1,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.document_upload,
                  title: 'Upload Report',
                  subtitle: 'Share your medical documents',
                  iconColor: AppTheme.success,
                  onTap: () {
                    if (_patientData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportUploadPage(
                            dio: _dio,
                            patientId: _patientData!['id'],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const Gap(12),
          AnimationConfiguration.staggeredList(
            position: 2,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ActionCard(
                  icon: Iconsax.document_text,
                  title: 'View Reports',
                  subtitle: 'Access your medical history',
                  iconColor: AppTheme.warning,
                  onTap: () {
                    if (_patientData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportHistoryPage(
                            dio: _dio,
                            patientId: _patientData!['id'],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAppointments() {
    if (_patientData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientAppointmentPage(
            dio: _dio,
            patientId: _patientData!['id'],
          ),
        ),
      );
    }
  }

  void _navigateToReports() {
    if (_patientData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportHistoryPage(
            dio: _dio,
            patientId: _patientData!['id'],
          ),
        ),
      );
    }
  }

  void _showProfileDialog() {
    if (_patientData == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primaryBlue, width: 3),
                  ),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background
                        Container(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                        ),
                        // Head (circle)
                        Positioned(
                          top: 20,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryBlue.withOpacity(0.7),
                            ),
                          ),
                        ),
                        // Shoulders (semi-circle)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 80,
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.7),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(80),
                                topRight: Radius.circular(80),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                
                // Patient Name
                Text(
                  '${_patientData!['firstName'] ?? ''} ${_patientData!['lastName'] ?? ''}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                
                Text(
                  _patientData!['email'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                
                // Patient Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildProfileRow('Age', '${_patientData!['age'] ?? 'N/A'} years', Iconsax.calendar),
                      const Gap(12),
                      _buildProfileRow('Gender', _patientData!['gender'] ?? 'N/A', Iconsax.user),
                      const Gap(12),
                      _buildProfileRow('Phone', _patientData!['phoneNumber'] ?? 'N/A', Iconsax.call),
                      const Gap(12),
                      _buildProfileRow('Address', _patientData!['address'] ?? 'N/A', Iconsax.location),
                      if (_patientData!['medicalHistory'] != null && _patientData!['medicalHistory'].toString().isNotEmpty) ...[
                        const Gap(12),
                        _buildProfileRow('Medical History', _patientData!['medicalHistory'], Iconsax.health),
                      ],
                    ],
                  ),
                ),
                const Gap(24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to edit profile page
                        },
                        icon: const Icon(Iconsax.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Iconsax.close_circle),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Iconsax.logout,
                color: AppTheme.error,
              ),
              const Gap(8),
              Text('Logout'),
            ],
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: AppTheme.white,
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        _navigateToAppointments();
        break;
      case 2:
        _navigateToReports();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
              const Gap(16),
              Text(
                'Loading your dashboard...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.warning_2,
                size: 64,
                color: AppTheme.error,
              ),
              const Gap(16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.error,
                ),
              ),
              const Gap(8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              ElevatedButton.icon(
                onPressed: _fetchPatientData,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const Gap(24),
              _buildHealthTips(),
              const Gap(24),
              _buildQuickStats(),
              const Gap(24),
              _buildNearbyDoctors(),
              const Gap(24),
              _buildQuickActions(),
              const Gap(100),
            ],
          ),
        ),
      ),
    );
  }
}