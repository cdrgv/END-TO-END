import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'userview.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController=TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final url = Uri.parse("http://localhost:5002/api/auth/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name":_nameController.text,
        "gender":_genderController.text,
        "address":_addressController.text,
        "email": _emailController.text,
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
        SnackBar(content: Text(responseData["message"] ?? "Registration Failed")),
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
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.1),
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
        title: Text("Register", style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold, color: Colors.deepPurple[900],
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple[800]),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Userview()));
          },
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Pretty gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
                  width: w < 420 ? w * 0.99 : w < 700 ? w * 0.85 : w * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.13),
                        blurRadius: 16, offset: Offset(3, 14),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 34, vertical: 34),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'register-avatar',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.person, size: 54, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text("New User", style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, fontSize: 23, color: Color(0xFF492fad)
                        )),
                        SizedBox(height: 18),
                        _roundedTextForm(
                          label: 'Name',
                          icon: Icons.nat,
                          controller: _nameController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your name' : null,
                        ),
                        SizedBox(height: 18),
                        _roundedTextForm(
                          label: 'Gender',
                          icon: Icons.gesture_rounded,
                          controller: _genderController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your gender' : null,
                        ),
                        SizedBox(height: 18),
                        _roundedTextForm(
                          label: 'Address',
                          icon: Icons.add,
                          controller: _addressController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your address' : null,
                        ),
                        SizedBox(height: 18),
                        _roundedTextForm(
                          label: 'Email',
                          icon: Icons.email,
                          controller: _emailController,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your email' : null,
                        ),
                        SizedBox(height: 18),
                        _roundedTextForm(
                          label: 'Password',
                          icon: Icons.lock,
                          controller: _passwordController,
                          obscure: true,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your password' : null,
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                            ),
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Text('Register',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        )),
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),
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
