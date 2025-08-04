import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';

class OwnerRegisterScreen extends StatefulWidget {
  @override
  _OwnerRegisterScreenState createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController=TextEditingController();
  final _phoneController = TextEditingController();
  final _ownerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int _currentStep = 1;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final url = Uri.parse("http://localhost:5002/register-owner");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text,
        "shopname": _shopController.text,
        "address": _addressController.text,
        "category": _categoryController.text,
        "phone": _phoneController.text,
        "latitude": _latitudeController.text,
        "longitude": _longitudeController.text,
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
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
      validator: (value) {
        if (value!.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepBubble(1, "Details"),
        Container(width: 40, height: 2, color: _currentStep >= 2 ? Colors.deepPurple : Colors.grey[300]),
        _stepBubble(2, "Contact"),
      ],
    );
  }

  Widget _stepBubble(int step, String label) {
    final selected = _currentStep == step;
    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 260),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple : Colors.white,
            border: Border.all(
              color: selected ? Colors.deepPurple : Colors.grey[400]!,
              width: selected ? 3 : 2,
            ),
            shape: BoxShape.circle,
            boxShadow: selected
                ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.21), blurRadius: 12, offset: Offset(2, 6))]
                : [],
          ),
          child: Center(child: Text('$step', style: GoogleFonts.montserrat(
            color: selected ? Colors.white : Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ))),
        ),
        SizedBox(height: 6),
        Text(label, style: GoogleFonts.montserrat(
          fontSize: 13,
          color: selected ? Colors.deepPurple : Colors.grey[600],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    );
  }

  Widget _buildContainer1() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Owner Name', Icons.person),
        SizedBox(height: 18),
        _buildTextField(_shopController, 'Shop Name', Icons.storefront_outlined),
        SizedBox(height: 18),
        _buildTextField(_addressController, 'Address', Icons.location_on),
        SizedBox(height: 18),
        _buildTextField(_categoryController, 'Category', Icons.category),
        SizedBox(height: 18),
        _buildTextField(_ownerController, 'Username', Icons.person_outline),
        SizedBox(height: 18),
        _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
        SizedBox(height: 32),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              elevation: 3,
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep = 2);
              }
            },
            child: Text('Next', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildContainer2() {
    return Column(
      children: [
        _buildTextField(_phoneController, 'Phone Number', Icons.phone),
        SizedBox(height: 18),
        _buildTextField(_latitudeController, 'Latitude', Icons.map),
        SizedBox(height: 18),
        _buildTextField(_longitudeController, 'Longitude', Icons.map),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              onPressed: () => setState(() => _currentStep = 1),
              child: Text('Previous', style: GoogleFonts.montserrat()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                elevation: 3,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showConfirmationPage();
                }
              },
              child: Text('Register', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  void _showConfirmationPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FadeIn(
          duration: Duration(milliseconds: 300),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(Icons.verified, color: Colors.deepPurple, size: 30),
                SizedBox(width: 12),
                Text("Confirm Registration", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationRow("Owner Name", _nameController.text),
                  _buildConfirmationRow("Shop Name", _shopController.text),
                  _buildConfirmationRow("Address", _addressController.text),
                  _buildConfirmationRow("category", _categoryController.text),
                  _buildConfirmationRow("Username", _ownerController.text),
                  _buildConfirmationRow("Phone", _phoneController.text),
                  _buildConfirmationRow("Latitude", _latitudeController.text),
                  _buildConfirmationRow("Longitude", _longitudeController.text),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Edit", style: GoogleFonts.montserrat()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                        _register();
                      },
                child: _isLoading
                    ? SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Text("Confirm", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text("$label: ", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat())),
        ],
      ),
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
        title: Text('Owner Registration', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==== Gorgeous background ====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F53AC), Color(0xFFfbc2eb)],
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
                duration: Duration(milliseconds: 750),
                child: Container(
                  width: w < 420 ? w * 0.99 : w < 700 ? w * 0.88 : w * 0.54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.11),
                        blurRadius: 20, offset: Offset(4, 14),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 33),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'register-avatar',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.store, size: 55, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("New Owner Registration", style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF512a96)
                        )),
                        SizedBox(height: 24),
                        _buildStepper(),
                        SizedBox(height: 23),
                        _currentStep == 1 ? _buildContainer1() : _buildContainer2(),
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
