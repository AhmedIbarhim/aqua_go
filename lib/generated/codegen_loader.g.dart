// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _ar = {
  "skip": "تخطي",
  "next": "التالي",
  "get_started": "ابدأ",
  "onboarding": {
    "title1": "مرحبا بكم في AquaGo",
    "title2": "جودة عالية",
    "title3": "توصيل سريع",
    "desc1": "منصتك المفضلة لمنتجات المياه عالية الجودة.",
    "desc2": "استمتع بأفضل تشكيلة من ماركات المياه والمنتجات ذات الصلة.",
    "desc3": "احصل على طلباتك بسرعة وكفاءة مع خدمة التوصيل لدينا."
  },
  "language": {
    "english": "الانجليزية",
    "arabic": "العربية"
  },
  "auth": {
    "login": "تسجيل الدخول",
    "verify_phone": "التحقق من رقم الهاتف",
    "phone_number": "رقم الهاتف",
    "send_verification_code": "إرسال رمز التحقق",
    "already_have_account": "هل لديك حساب بالفعل؟",
    "login_here": "سجل الدخول هنا",
    "verify_otp": "التحقق من رمز OTP",
    "resend_code": "إعادة إرسال الرمز",
    "didnt_receive_code": "لم تستلم رمزاً؟",
    "enter_verification_code": "أدخل رمز التحقق المرسل إلى",
    "seconds": "ثواني",
    "verify": "تحقق"
  }
};
static const Map<String,dynamic> _en = {
  "skip": "skip",
  "next": "next",
  "get_started": "get started",
  "onboarding": {
    "title1": "Welcome to AquaGo",
    "title2": "Premium Quality",
    "title3": "Fast Delivery",
    "desc1": "Your go-to platform for high-quality water products delivered right to your doorstep.",
    "desc2": "Experience the best selection of premium water brands and related products.",
    "desc3": "Get your orders quickly and reliably with our efficient delivery service."
  },
  "language": {
    "english": "English",
    "arabic": "Arabic"
  },
  "auth": {
    "login": "Login",
    "verify_phone": "Verify Phone Number",
    "phone_number": "Phone Number",
    "send_verification_code": "Send Verification Code",
    "already_have_account": "Already have an account?",
    "login_here": "Login here",
    "verify_otp": "Verify OTP",
    "resend_code": "Resend Code",
    "didnt_receive_code": "Didn't receive a code?",
    "enter_verification_code": "Enter verification code sent to",
    "seconds": "seconds",
    "verify": "Verify"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar": _ar, "en": _en};
}
