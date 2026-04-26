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
    "continue_as_guest": "المتابعة كزائر",
    "verify_phone": "تحقق من رقم جوالك",
    "phone_number": "رقم التليفون",
    "send_verification_code": "سنرسل لك رمز تحقق عبر رسالة نصية",
    "verify_otp": "تحقق من رقم جوالك",
    "resend_code": "إعادة إرسال الرمز خلال",
    "resend_code_button": "إعادة إرسال الرمز",
    "enter_verification_code": "أدخل رمز التحقق المرسل إلى",
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
    "login": "login",
    "continue_as_guest": "Continue as Guest",
    "verify_phone": "Verify Phone Number",
    "phone_number": "Phone Number",
    "send_verification_code": "We'll send you a verification code via SMS",
    "verify_otp": "Verify your phone number",
    "resend_code": "Resend Code within",
    "resend_code_button": "Resend Code",
    "enter_verification_code": "Enter verification code sent to",
    "verify": "Verify"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar": _ar, "en": _en};
}
