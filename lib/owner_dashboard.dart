import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class OwnerDashboard extends StatefulWidget {
  final String username;
  final String shopName;
  OwnerDashboard({required this.username, required this.shopName});
  @override
  _OwnerDashboardState createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String _currentStatus = 'closed';
  bool _showProfilePanel = false;
  Map<String, dynamic> _ownerDetails = {};
  bool _loadingOwnerDetails = true;

  @override
  void initState() {
    super.initState();
    _fetchOwnerDetails();
    _fetchShopStatus();
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'open':
        return Colors.green.shade600;
      case 'closed':
        return Colors.red.shade600;
      case 'resume':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _fetchOwnerDetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5002/owner/${widget.username}'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _ownerDetails = decoded;
            _loadingOwnerDetails = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching owner details: $e");
    }
  }

  Future<void> _fetchShopStatus() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5002/shop-status/${widget.username}'));
      if (response.statusCode == 200) {
        setState(() {
          _currentStatus = jsonDecode(response.body)['status'];
        });
      }
    } catch (e) {
      print("Error fetching shop status: $e");
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5002/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username, 'status': newStatus}),
      );
      if (response.statusCode == 200) {
        setState(() => _currentStatus = newStatus);
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text('Do you want to logout?', style: GoogleFonts.montserrat()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // --- Main Build ---
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ==== Beautiful Gradient BG ====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFb1b2ff), Color(0xFFfad0c4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
          ),
          // ==== Blurred floating profile panel ====
          AnimatedPositioned(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            left: _showProfilePanel ? 0 : -w * 0.53,
            top: 0,
            bottom: 0,
            width: w < 420 ? w * 0.94 : w * 0.38,
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
                  child: Container(
                    color: Colors.white.withOpacity(0.93),
                    child: _profilePanelContent(context),
                  ),
                ),
              ),
            ),
          ),
          // ==== Main dashboard ====
          GestureDetector(
            onTap: () {
              if (_showProfilePanel) setState(() => _showProfilePanel = false);
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.deepPurple.withOpacity(0.92),
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  widget.shopName,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 21),
                ),
                leading: IconButton(
                  icon: Icon(Icons.account_circle, size: 29, color: Colors.white),
                  onPressed: () => setState(() => _showProfilePanel = !_showProfilePanel),
                  tooltip: "Profile/Settings",
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.exit_to_app, color: Colors.white),
                    tooltip: "Logout",
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: w < 500 ? 8 : 0, vertical: 18),
                    child: GlassDashboardCard(
                      status: _currentStatus,
                      statusColor: _getStatusColor(),
                      onStatusChange: _updateStatus,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePanelContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.deepPurple[200],
                    child: Padding(
                      padding: EdgeInsets.all(7),
                      child: Image.asset(
                        'web/logo1.png',
                        height: 33,
                        width: 33,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Status Hub",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Color(0xFF33344b)),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade400),
                    onPressed: () => setState(() => _showProfilePanel = false),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: _ownerDetails.isNotEmpty && _ownerDetails['profileImage'] != null
                        ? NetworkImage(_ownerDetails['profileImage'])
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: _ownerDetails.isEmpty || _ownerDetails['profileImage'] == null
                        ? Icon(Icons.person, size: 29, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loadingOwnerDetails
                              ? "Loading profile..."
                              : "Hello, ${_ownerDetails['name'] ?? 'Owner'}",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!_loadingOwnerDetails)
                          Text(
                            widget.shopName,
                            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),
              Divider(color: Colors.grey.shade300, thickness: 1, endIndent: 15),
              SizedBox(height: 18),
              Text("Quick Actions", style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 15)),
              SizedBox(height: 14),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.settings, color: Colors.blue[400], size: 28),
                  title: Text("Settings", style: GoogleFonts.montserrat(fontSize: 13)),
                  onTap: () {} // Open settings page 
              ),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.help_outline, color: Colors.green, size: 28),
                  title: Text("Help", style: GoogleFonts.montserrat(fontSize: 13)),
                  onTap: () {}
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: OutlinedButton.icon(
                  icon: Icon(Icons.logout, color: Colors.redAccent),
                  label: Text("Logout", style: GoogleFonts.montserrat(color: Colors.redAccent)),
                  onPressed: () {
                    setState(() => _showProfilePanel = false);
                    _showLogoutDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )
            ]
        ),
      ),
    );
  }
}

// =================== GLASS CARD DASHBOARD ======================
class GlassDashboardCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final Function(String status) onStatusChange;

  const GlassDashboardCard({
    required this.status,
    required this.statusColor,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: w < 460 ? w * 0.98 : 390,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.89),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.09),
                  blurRadius: 20,
                  offset: Offset(2, 12),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Current Status",
                style: GoogleFonts.montserrat(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple[700]),
              ),
              SizedBox(height: 25),
              AnimatedContainer(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.21),
                      blurRadius: 46,
                      spreadRadius: 3,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusButton(label: 'Closed', color: Colors.red, selected: status == 'closed', onTap: onStatusChange),
                  SizedBox(width: 13),
                  _StatusButton(label: 'Resume', color: Colors.amber.shade700, selected: status == 'resume', onTap: onStatusChange),
                  SizedBox(width: 13),
                  _StatusButton(label: 'Open', color: Colors.green.shade600, selected: status == 'open', onTap: onStatusChange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final Function(String) onTap;

  const _StatusButton({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onTap(label.toLowerCase()),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : color.withOpacity(0.19),
        elevation: selected ? 6 : 0,
        foregroundColor: Colors.white,
        side: BorderSide(color: !selected ? color : Colors.transparent, width: 1.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        padding: EdgeInsets.symmetric(horizontal: 23, vertical: 13),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }
}
