class Validator {
  static String? validateMobileAndEmail(String? value) {
    if (value!.isEmpty) {
      return "Please Enter the Email or Mobile number";
    } else if ((!RegExp(r'(^(?:[+0]9)?[0-9]{10}$)').hasMatch(value))) {
      if (!RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(value)) {
        return "Please Enter a valid email or mobile number";
      }
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value!.isEmpty) {
    return "Please enter the mobile number";
  } else if ((!RegExp(r'^[6789]\d{9}$').hasMatch(value))) {
    return "Please enter a valid mobile number";
  } else if (RegExp(r'^(\d)\1{9}$').hasMatch(value)) {
    return "Please enter a valid mobile number";
  }
  return null;
  }

  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Please enter the E-mail";
    } else if ((!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value))) {
      return "Please Enter a valid E-mail";
    }
    return null;
  }

  static String? validateAccountNum(String? value) {
    if (value!.length <= 25) {
      try {
        int _ = int.parse(value);
        return null;
      } catch (e) {
        return "Please enter a valid Account number.";
      }
    } else {
      return "Please enter a valid Account number.";
    }
  }

  static String? validatePin(String? value) {
    if (value!.length == 6) {
      try {
        int _ = int.parse(value);
        return null;
      } catch (e) {
        return "Please enter a valid Pincode.";
      }
    } else {
      return "Please enter a valid Pincode.";
    }
  }

  static String? notEmpty(String? value) {
    if (value == "") {
      return "Field cannot be empty";
    }
    return null;
  }

  static String? checkMatch(String? value, String original, String errorText) {
    if (value == original) {
      return null;
    }
    return errorText;
  }

  static String? validatePassword(String? passValue) {
    String patternPass =
        // r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
        "^[A-Za-z0-9!@#\$*~?/]";
    RegExp regex = RegExp(patternPass);
    print(passValue);
    if (passValue!.length < 5) {
      return "Password must be more than 5 letters";
    } else if (passValue.isEmpty) {
      return "Please enter password";
    } else if (!regex.hasMatch(passValue)) {
      return "Please enter Password";
    } else
      return null;
  }

  static String? validatePan(String? value) {
    String pan_pattern = "[A-Z]{5}[0-9]{4}[A-Z]{1}";
    RegExp regex = new RegExp(pan_pattern);
    if (value!.isEmpty) {
      return "Please enter a PAN number.";
    } else if (value.length != 10) {
      return "Please enter a valid PAN number.";
    } else if (!regex.hasMatch(value)) {
      return "Please enter a valid PAN number.";
    } else {
      return null;
    }
  }

  static String? validateAadhar(String? aadharValue) {
    String patternAadhar = "^[0-9]";
    RegExp regex = RegExp(patternAadhar);
    if (aadharValue!.isEmpty) {
      return "Please Enter Aadhar number";
    } else if (aadharValue.length > 12 || aadharValue.length < 12) {
      return 'Enter valid Aadhar number';
    } else if (!regex.hasMatch(aadharValue)) {
      return 'Enter valid Aadhar number';
    } else {
      return null;
    }
  }

  static String? validateifsc(String? value) {
    String ifscPattern = "^[A-Z]{4}0[A-Z0-9]{6}";
    RegExp regex = new RegExp(ifscPattern);
    if (value!.isEmpty) {
      return "Please enter a IFSC Code.";
    } else if (value.length != 11) {
      return "Please enter a valid IFSC Code.";
    } else if (!regex.hasMatch(value)) {
      return "Please enter a valid IFSC Code.";
    } else {
      return null;
    }
  }

  static String? validateGst(String? value) {
    String pan_pattern =
        "^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}";
    RegExp regex = new RegExp(pan_pattern);
    if (value!.isEmpty) {
      return "Please enter a GST number.";
    } else if (value.length != 15) {
      return "Please enter a valid GST number.";
    } else if (!regex.hasMatch(value)) {
      return "Please enter a valid GST number.";
    } else {
      return null;
    }
  }
}
