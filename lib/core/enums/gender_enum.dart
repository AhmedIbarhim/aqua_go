enum Gender { male, female }

extension GenderEnumExtension on Gender {
  String nameAr() {
    switch (this) {
      case Gender.male:
        return 'ذكر';
      case Gender.female:
        return 'أنثى';
    }
  }

  String nameEn() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  static Gender fromString(String? gender) {
    if (gender == null) return Gender.male;
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.male; // Fallback to male instead of throwing
    }
  }
}
