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
  "edit": "تعديل",
  "delete": "حذف",
  "onboarding": {
    "title1": "نظافة السيارة بسهولة",
    "title2": "تألق في أي وقت وأي مكان",
    "title3": "خبراء غسيل موثوقين",
    "desc1": "خدمات غسيل سيارات احترافية تصل إلى موقعك ببضع نقرات فقط.",
    "desc2": "استمتع بغسيل سيارتك وأنت في منزلك أو مكتبك بكل سهولة",
    "desc3": "حلول تنظيف عالية الجودة مصممة للحفاظ على سيارتك في أفضل حالاتها."
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
  },
  "layout": {
    "home": "الرئيسية",
    "my_cars": "سياراتي",
    "reservations": "الحجوزات",
    "profile": "البروفايل",
    "welcome": "مرحباً",
    "ready_to_serve": "نحن جاهزون لخدمتك"
  },
  "home": {
    "available_packages": "الباقات المتاحة",
    "best_offers": "أفضل العروض",
    "available_offers": "العروض المتاحة",
    "view_more": "عرض المزيد",
    "notifications": "الإشعارات"
  },
  "my_cars": {
    "empty_state": "لا توجد سيارات مسجلة",
    "empty_desc": "سيتم عرض السيارات الخاصة بك في هذه الصفحة في حالة اضافتها",
    "add_car": "إضافة سيارة جديدة"
  },
  "booking_package": {
    "success": "عملية ناجحة",
    "description": "تم الاشتراك في الباقة بنجاح يمكنك استخدامها بدءاً من الان",
    "request_wash": "اطلب اول غسلة",
    "go_to_home": "الذهاب للرئيسية",
    "package_details": "تفاصيل الباقة",
    "duration": "لمدة : ",
    "total": "الإجمالي",
    "buy_package": "اشتراك في الباقة",
    "buy": "اشترك الآن"
  }
};
static const Map<String,dynamic> _en = {
  "skip": "skip",
  "next": "next",
  "get_started": "get started",
  "edit": "edit",
  "delete": "delete",
  "onboarding": {
    "title1": "Effortless Car Care",
    "title2": "Shine Anytime, Anywhere",
    "title3": "Trusted Wash Experts",
    "desc1": "Professional car wash services delivered to your location with just a few taps.",
    "desc2": "Book, track, and enjoy seamless car care from the comfort of your home or office.",
    "desc3": "Premium cleaning solutions tailored to keep your car looking its best."
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
  },
  "layout": {
    "home": "Home",
    "my_cars": "My Cars",
    "reservations": "Reservations",
    "profile": "Profile",
    "welcome": "Welcome",
    "ready_to_serve": "We are ready to serve you"
  },
  "home": {
    "available_packages": "Available Packages",
    "best_offers": "Best Offers",
    "available_offers": "Available Offers",
    "view_more": "View More",
    "notifications": "Notifications"
  },
  "my_cars": {
    "empty_state": "No cars added yet",
    "empty_desc": "Your vehicles will appear here once you add them",
    "add_car": "Add New Car"
  },
  "booking_package": {
    "success": "Successful process",
    "description": "You have successfully subscribed to the package. You can use it starting now.",
    "request_wash": "Request First Wash",
    "go_to_home": "Go to Home",
    "package_details": "Package Details",
    "duration": "Duration: ",
    "total": "Total",
    "buy_package": "Subscribe to Package",
    "buy": "Subscribe Now"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar": _ar, "en": _en};
}
