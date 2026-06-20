const String kNotFirstUse = "kNotFirstUse";
const String kLanguage = "kLanguage";
const String kArabicLang = "ar";
const String kEnglishLang = "en";
const String kThemeMode = "kThemeMode";
const String kUserData = "kUserData";
const String kAccessToken = "kAccessToken";
const String kRefreshToken = "kRefreshToken";
const String kIsGuest = "kIsGuest";
// Written to SharedPrefs on first launch; absent after a fresh install
// (SharedPrefs wiped) so we can detect a Keychain-survives-reinstall scenario.
const String kSessionInstallMarker = "kSessionInstallMarker";
