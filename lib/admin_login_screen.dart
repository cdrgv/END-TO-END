import 'dart:convert';
import 'dart:ui'; // <-- Add this line
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import 'superadminpage.dart';
import 'adminpage.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String _selectedAdmin = 'admin1';
  final TextEditingController _adminUserController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _admin2UserController = TextEditingController();
  final TextEditingController _admin2PasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginSuperAdmin() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://localhost:5002/superadminlogin');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _adminUserController.text.trim(),
          "password": _adminPasswordController.text.trim(),
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAdminPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loginAdmin() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://localhost:5002/admin-login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _admin2UserController.text.trim(),
          "password": _admin2PasswordController.text.trim(),
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to connect to the server')),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _buildAdminSelectionToggle() {
    // Toggle look for role selection
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F53AC), Color(0xFF657CED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ToggleButtons(
        isSelected: [_selectedAdmin == "admin1", _selectedAdmin == "admin2"],
        borderRadius: BorderRadius.circular(14),
        fillColor: Colors.deepPurple.withOpacity(0.09),
        selectedColor: Colors.white,
        borderColor: Colors.transparent,
        splashColor: Colors.deepPurpleAccent.withOpacity(0.13),
        selectedBorderColor: Colors.transparent,
        onPressed: (int i) {
          setState(() => _selectedAdmin = (i == 0 ? 'admin1' : 'admin2'));
        },
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            child: Text(
              'Super Admin',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: _selectedAdmin == "admin1" ? Colors.white : Colors.white.withOpacity(0.78)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            child: Text(
              'Admin',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: _selectedAdmin == "admin2" ? Colors.white : Colors.white.withOpacity(0.78)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _adminUserController,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Super Admin Username', icon: Icons.person),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _adminPasswordController,
          obscureText: true,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Password', icon: Icons.lock),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginSuperAdmin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.2,
                    ),
                  )
                : Text('Login',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _admin2UserController,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Admin Username', icon: Icons.person),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _admin2PasswordController,
          obscureText: true,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Password', icon: Icons.lock),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginAdmin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.2,
                    ),
                  )
                : Text('Login',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  InputDecoration _roundedInputDecoration(String label, {required IconData icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Color(0xFFF7F7FA),
      labelText: label,
      labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w400),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(13)),
      prefixIcon: Icon(icon, color: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Admin Login",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade900)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BG GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F53AC), Color(0xFF657CED), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glass blur only for wide
          if (w > 700)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(color: Colors.transparent),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              child: FadeInDown(
                duration: Duration(milliseconds: 650),
                child: Container(
                  width: w < 440
                      ? w * 0.97
                      : w < 710
                          ? w * 0.78
                          : w * 0.45,
                  padding: EdgeInsets.symmetric(
                      vertical: 36, horizontal: w < 530 ? 10 : 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.18),
                        blurRadius: 19,
                        offset: Offset(2, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFF7F53AC),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(
                            'web/logo1.png',
                            height: 80,
                            width: 80,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text("Welcome Admin",
                          style: GoogleFonts.montserrat(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF462a7f))),
                      SizedBox(height: 10),
                      _buildAdminSelectionToggle(),
                      SizedBox(height: 24),
                      _selectedAdmin == 'admin1'
                          ? _buildSuperAdminLoginForm()
                          : _buildAdminLoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
