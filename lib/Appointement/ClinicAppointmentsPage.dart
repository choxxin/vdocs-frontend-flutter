import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Appointement/ClinicAppointmentDetailPage.dart';

class ClinicAppointmentsPage extends StatefulWidget {
  final Dio dio;

  const ClinicAppointmentsPage({super.key, required this.dio});

  @override
  State<ClinicAppointmentsPage> createState() => _ClinicAppointmentsPageState();
}

class _ClinicAppointmentsPageState extends State<ClinicAppointmentsPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _appointments = [];
  List<dynamic> _filteredAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;
  int _currentTabIndex = 0;

  final List<String> _statusFilters = ['CONFIRMED', 'PENDING', 'CANCELLED'];
  final Map<String, String> _statusDisplayNames = {
    'CONFIRMED': 'Confirmed',
    'PENDING': 'Pending',
    'CANCELLED': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _filterAppointments();
        });
      }
    });
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterAppointments() {
    final selectedStatus = _statusFilters[_currentTabIndex];
    final filtered = _appointments
        .where((appt) => appt['status'] == selectedStatus)
        .toList();
    setState(() => _filteredAppointments = filtered);
  }

  Future<void> _fetchAppointments() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await widget.dio.get(
        "http://10.0.2.2:8080/api/clinic/appointments/all",
      );

      if (!mounted) return;
      setState(() {
        _appointments = response.data;
        _filterAppointments();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'CONFIRMED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EmptyStateAnimation(status: _statusFilters[_currentTabIndex]),
          const SizedBox(height: 24),
          Text(
            "No ${_statusDisplayNames[_statusFilters[_currentTabIndex]]!.toLowerCase()} appointments",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try a different filter or check back later",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 141, 130, 130),
        title: const Text("Appointments"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ColoredBox(
            color: const Color(0xFF1F1F1F),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 3,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: _statusFilters
                  .map((status) => Tab(
                        text: _statusDisplayNames[status],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchAppointments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: _filteredAppointments.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _filteredAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment =
                                    _filteredAppointments[index];
                                final clinicName =
                                    appointment['clinic']?['name'] ??
                                        'Unknown Clinic';
                                final status =
                                    appointment['status'] ?? 'Unknown';
                                final medicalRequirement =
                                    appointment['medicalRequirement'] ?? '';
                                final date =
                                    appointment['appointmentDate'] ?? '';

                                return Card(
                                  color: const Color(0xFF1E1E1E),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: Container(
                                      width: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "${appointment['patientName']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          "Clinic: $clinicName",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Date: $date",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Medical Requirement: $medicalRequirement",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ClinicAppointmentDetailPage(
                                            dio: widget.dio,
                                            appointmentId: appointment['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAppointments,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
        mini: true,
      ),
    );
  }
}

// ------------------- Empty State Animation -------------------

class _EmptyStateAnimation extends StatefulWidget {
  final String status;

  const _EmptyStateAnimation({super.key, required this.status});

  @override
  State<_EmptyStateAnimation> createState() => __EmptyStateAnimationState();
}

class __EmptyStateAnimationState extends State<_EmptyStateAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.access_time;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getStatusIconColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blueAccent;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _getStatusIconColor(widget.status).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStatusIcon(widget.status),
          size: 60,
          color: _getStatusIconColor(widget.status),
        ),
      ),
    );
  }
}
