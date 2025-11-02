import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Appointement/ClinicAppointmentsPage.dart';
import '../core/services/auth_service.dart';

class ClinicHomePage extends StatefulWidget {
  @override
  _ClinicHomePageState createState() => _ClinicHomePageState();
}

class _ClinicHomePageState extends State<ClinicHomePage> {
  late final Dio _dio;
  Map<String, dynamic>? _clinicData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeDio());
  }

  void _initializeDio() async {
    final Dio? passedDio = ModalRoute.of(context)?.settings.arguments as Dio?;
    
    if (passedDio != null) {
      _dio = passedDio;
    } else {
      // Use the shared AuthService instance to maintain session
      _dio = await AuthService().getDio();
    }

    _fetchClinicData();
  }

  Future<void> _fetchClinicData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _dio.get("http://10.0.2.2:8080/api/clinic/auth/me");

      if (response.statusCode == 200) {
        setState(() {
          _clinicData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch clinic data";
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

  Future<void> _fetchCompletedAppointments() async {
    try {
      final response = await _dio.get("http://10.0.2.2:8080/api/clinic/appointments/completed");

      if (response.statusCode == 200) {
        final List<dynamic> appointments = response.data;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompletedAppointmentsPage(
              dio: _dio,
              appointments: appointments,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch appointments: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 141, 130, 130),
        title: Text("Clinic Dashboard"),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchClinicData),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Clear session cookies
              await AuthService().clearSession();
              
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _fetchClinicData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClinicInfoCard(),
                        SizedBox(height: 24),
                        Text(
                          "Dashboard",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildDashboardCard(
                              icon: Icons.people,
                              title: "Patients",
                              onTap: _fetchCompletedAppointments,
                            ),
                            _buildDashboardCard(
                              icon: Icons.calendar_today,
                              title: "Appointments",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClinicAppointmentsPage(dio: _dio),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchClinicData, child: Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildClinicInfoCard() {
    if (_clinicData == null) return SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, size: 32, color: Colors.blueAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _clinicData!['name'] ?? 'Unknown Clinic',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[400]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: Colors.white24),
            SizedBox(height: 16),
            _buildInfoRow(Icons.email, "Email", _clinicData!['email'] ?? 'N/A'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.phone, "Contact", _clinicData!['contactNo'] ?? 'N/A'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, "Address", _clinicData!['address'] ?? 'N/A'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, "Created", _formatDate(_clinicData!['createdAt'])),
            SizedBox(height: 12),
            _buildInfoRow(Icons.update, "Last Updated", _formatDate(_clinicData!['updatedAt'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500)),
              SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDashboardCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blueAccent),
              SizedBox(height: 16),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedAppointmentsPage extends StatelessWidget {
  final Dio dio;
  final List<dynamic> appointments;

  const CompletedAppointmentsPage({super.key, required this.dio, required this.appointments});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.greenAccent;
      case 'PENDING':
        return Colors.orangeAccent;
      case 'CANCELLED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Completed Appointments"),
        backgroundColor: const Color.fromARGB(255, 141, 130, 130),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final clinic = appointment['clinic'] ?? {};
          final status = appointment['status'] ?? 'Unknown';

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.grey[850],
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                appointment['patientName'] ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text("Clinic: ${clinic['name'] ?? 'N/A'}", style: TextStyle(color: Colors.white70)),
                  Text("Date: ${appointment['appointmentDate'] ?? 'N/A'}", style: TextStyle(color: Colors.white70)),
                  Text("Requirement: ${appointment['medicalRequirement'] ?? 'N/A'}", style: TextStyle(color: Colors.white70)),
                  if ((appointment['remarks'] ?? '').isNotEmpty)
                    Text("Remarks: ${appointment['remarks']}", style: TextStyle(color: Colors.white70)),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
