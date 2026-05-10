enum GenderEnum { male, female }

extension GenderEnumExtension on GenderEnum {
  String nameAr() {
    switch (this) {
      case GenderEnum.male:
        return 'ذكر';
      case GenderEnum.female:
        return 'أنثى';
    }
  }

  String nameEn() {
    switch (this) {
      case GenderEnum.male:
        return 'Male';
      case GenderEnum.female:
        return 'Female';
    }
  }
}
