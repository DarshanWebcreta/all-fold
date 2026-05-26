class Validation {
  Validation._();

  static String? pass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field*';
    }
    return null;
  }

  static String? barcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    // else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    //   return 'Please enter a valid email address';
    // }
    return null;
  }

}
