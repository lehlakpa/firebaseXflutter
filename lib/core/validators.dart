class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains('@')) {
      return "Enter valid email";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  static String? contactNumber(String? value) {
    if (value == null || value.isEmpty) return "Contact number is required";
    String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 10) {
      return "Phone number must be exactly 10 digits";
    }
    return null;
  }

  static String? province(String? value) {
    if (value == null || value.isEmpty) return "Province is required";
    return null;
  }

  static String? tole(String? value) {
    if (value == null || value.isEmpty) return "Tole/street is required";
    return null;
  }
}
