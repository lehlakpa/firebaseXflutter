import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _toleController = TextEditingController();

  String _province = '';
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Modern Theme Colors
  final Color primaryBlue = const Color(0xFF007BFF);
  final Color bgGrey = const Color(0xFFF8F9FA);
  final Color borderGrey = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactNumberController.dispose();
    _toleController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        province: _province,
        tole: _toleController.text.trim(),
      );

      await user?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created! Please verify your email."),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message.replaceAll("Exception:", "")),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Join Us!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Please fill in the details to get started.",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              /// Email
              TextFormField(
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("Email Address", Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              /// Password Row (To keep form shorter)
              TextFormField(
                controller: _passwordController,
                validator: Validators.password,
                obscureText: _obscurePassword,
                decoration: _inputStyle("Password", Icons.lock_outline)
                    .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                validator: Validators.password,
                decoration: _inputStyle("Confirm Password", Icons.lock_reset),
              ),
              const SizedBox(height: 20),

              /// Contact and Province in a Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _contactNumberController,
                      validator: Validators.contactNumber,
                      keyboardType: TextInputType.phone,
                      decoration: _inputStyle("Phone", Icons.phone_android),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _province.isEmpty ? null : _province,
                      validator: Validators.province,
                      decoration: _inputStyle("Province", Icons.map_outlined),
                      items:
                          [
                                'Koshi',
                                'Madhesh',
                                'Bagmati',
                                'Gandaki',
                                'Lumbini',
                                'Karnali',
                                'Sudurpashchim',
                              ]
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _province = val ?? ''),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Tole / Street
              TextFormField(
                controller: _toleController,
                validator: Validators.tole,
                decoration: _inputStyle(
                  "Street / Tole (Google Maps Address)",
                  Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 40),

              /// Register Button
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "REGISTER",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
