import 'dart:convert';
import 'dart:ui';
import 'owner_dashboard.dart';
import 'dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:status_hub/userview.dart';
import 'admin_login_screen.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedRole = 'user';
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _ownerPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://localhost:5002/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": _userController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              email: _userController.text.trim(),
            ),
          ),
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

  Future<void> _loginOwner() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('http://localhost:5002/owner-login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _ownerController.text.trim(),
          "password": _ownerPasswordController.text.trim(),
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerDashboard(
              username: _ownerController.text.trim(),
              shopName: data['shopname'] ?? '', // Make sure 'shopname' is returned from your API
            ),
          ),
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
        isSelected: [_selectedRole == "user", _selectedRole == "owner"],
        borderRadius: BorderRadius.circular(14),
        fillColor: Colors.deepPurple.withOpacity(0.09),
        selectedColor: Colors.white,
        borderColor: Colors.transparent,
        splashColor: Colors.deepPurpleAccent.withOpacity(0.13),
        selectedBorderColor: Colors.transparent,
        onPressed: (int i) {
          setState(() => _selectedRole = (i == 0 ? 'user' : 'owner'));
        },
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            child: Text(
              'Login as User',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: _selectedRole == "user" ? Colors.white : Colors.white.withOpacity(0.78)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            child: Text(
              'Owner Login',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: _selectedRole == "owner" ? Colors.white : Colors.white.withOpacity(0.78)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _userController,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Email', icon: Icons.email),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Password', icon: Icons.lock),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
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

  Widget _buildOwnerLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _ownerController,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Owner Username', icon: Icons.person),
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _ownerPasswordController,
          obscureText: true,
          style: GoogleFonts.montserrat(),
          decoration: _roundedInputDecoration('Password', icon: Icons.lock),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginOwner,
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
  Future<void> _sendOtp() async {
    final email = _userController.text.trim();
    if (email.isEmpty) {
      _showAlertDialog("Error", "Please enter your email");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5002/send-otp"), // <-- Use your Mac's IP
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _isOtpSent = true);
        _showAlertDialog("Success", "OTP sent to your email");
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Failed to send OTP");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
  }
  Future<void> _verifyOtp() async {
    final email = _userController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showAlertDialog("Error", "Please enter the OTP");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5002/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _isOtpVerified = true);
        _showAlertDialog("Success", "OTP Verified. You can reset your password");
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Invalid OTP");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
  }
  Future<void> _resetPassword() async {
    final email = _userController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      _showAlertDialog("Error", "Please enter a new password");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5002/reset-password"), // <-- Use your Mac's IP
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showAlertDialog("Success", "Password reset successfully. You can now login.");
        setState(() {
          _isOtpSent = false;
          _isOtpVerified = false;
        });
      } else {
        _showAlertDialog("Error", responseData["error"] ?? "Failed to reset password");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to connect to the server");
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text(message, style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  
  

  

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Text("Login", style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple[900],
        )),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple[900]),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Userview()))
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent.shade100,
        child: Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
        tooltip: "Admin Login",
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AdminLoginScreen(),
            ),
          );
        },
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // BLUR for extra glass effect
          if (w > 650)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: FadeInDown(
              duration: Duration(milliseconds: 700),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: w < 500 ? 6 : 0),
                width: w < 420 ? w * 0.98 : w < 700 ? w * 0.85 : w * 0.47,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 23),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.86),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.10),
                            blurRadius: 23,
                            offset: Offset(6, 12),
                          )
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFa18cd1),
                              radius: 46,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('web/logo1.png', height: 62),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text("Sign in to your Account", 
                              style: GoogleFonts.montserrat(
                                fontSize: 23, fontWeight: FontWeight.bold,
                                color: Color(0xFF481e99)
                              )
                            ),
                            SizedBox(height: 18),
                            _buildAdminSelectionToggle(),
                            SizedBox(height: 24),
                            _selectedRole == 'user'
                          ? _buildUserLoginForm()
                          : _buildOwnerLoginForm(),
                            // Forgot password logic
                            if (_selectedRole == "user" && !_isOtpSent) ... [
                              SizedBox(height: 12),
                              TextButton(
                                onPressed: _sendOtp,
                                child: Text("Forgot Password?",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                            if (_isOtpSent && !_isOtpVerified) ...[
                              Divider(height: 32),
                              Text("Enter OTP sent to your email",
                                style: GoogleFonts.montserrat(
                                  color: Colors.deepPurple[600],
                                )
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: _otpController,
                                style: GoogleFonts.montserrat(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF7F7FA),
                                  labelText: "Enter OTP",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13)),
                                  prefixIcon: Icon(Icons.verified),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                  backgroundColor: Colors.deepPurpleAccent),
                                onPressed: _verifyOtp,
                                child: Text("Verify OTP", 
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontWeight: FontWeight.bold
                                  )),
                              ),
                            ],
                            if (_isOtpVerified) ... [
                              Divider(height: 32),
                              Text("Reset your password",
                                style: GoogleFonts.montserrat(
                                  color: Colors.deepPurple[600],
                                ),
                              ),
                              SizedBox(height: 6),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: true,
                                style: GoogleFonts.montserrat(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF7F7FA),
                                  labelText: "New Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13)),
                                  prefixIcon: Icon(Icons.lock_reset),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                  backgroundColor: Colors.deepPurpleAccent),
                                onPressed: _resetPassword,
                                child: Text("Reset Password", 
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white, fontWeight: FontWeight.bold
                                  )),
                              ),
                            ]
                          ],
                        ),
                      ),
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
}
