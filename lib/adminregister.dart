import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';

class AdminRegisterScreen extends StatefulWidget {
  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final url = Uri.parse("http://localhost:5002/register-admin");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text,
        "address": _addressController.text,
        "username": _ownerController.text,
        "password": _passwordController.text,
      }),
    );
    setState(() => _isLoading = false);
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registered Successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData["message"] ?? "Registration failed!")),
      );
    }
  }

  Widget _roundedTextForm({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF8F8FB),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.2),
          borderRadius: BorderRadius.circular(13),
        ),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
      ),
      validator: validator,
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
        title: Text('Register',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold, color: Colors.deepPurple[900],
          )),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Pretty background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Optional glass blur
          if (w > 560)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(color: Colors.transparent),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              child: FadeInDown(
                duration: Duration(milliseconds: 700),
                child: Container(
                  width: w < 420 ? w * 0.99 : w < 710 ? w * 0.9 : w * 0.53,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.13),
                        blurRadius: 18,
                        offset: Offset(4, 12),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.person, size: 55, color: Colors.white),
                        ),
                        SizedBox(height: 22),
                        Text("New Admin",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, fontSize: 23, color: Color(0xFF4d279c)
                          ),
                        ),
                        SizedBox(height: 28),
                        _roundedTextForm(
                          label: 'Admin Name',
                          icon: Icons.person,
                          controller: _nameController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your name' : null,
                        ),
                        SizedBox(height: 20),
                        _roundedTextForm(
                          label: 'Address',
                          icon: Icons.location_on,
                          controller: _addressController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your address' : null,
                        ),
                        SizedBox(height: 20),
                        _roundedTextForm(
                          label: 'Username',
                          icon: Icons.person_2_outlined,
                          controller: _ownerController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your username' : null,
                        ),
                        SizedBox(height: 20),
                        _roundedTextForm(
                          label: 'Password',
                          icon: Icons.lock,
                          controller: _passwordController,
                          obscure: true,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your password' : null,
                        ),
                        SizedBox(height: 34),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2.6,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Text('Register',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        )),
                                  ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
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
