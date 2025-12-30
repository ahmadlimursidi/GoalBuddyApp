
class AgeCalculator {
  /// Calculates the age in years from DOB
  static double calculateAgeInYears(DateTime dateOfBirth) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateOfBirth);
    double ageInDays = difference.inDays / 365.25; // Account for leap years
    return ageInDays;
  }

  /// Determines the appropriate age group for a child based on their age in years
  static String getAgeGroupForChild(double ageInYears) {
    if (ageInYears >= 1.5 && ageInYears < 2.5) {
      return 'Little Kicks';
    } else if (ageInYears >= 2.5 && ageInYears < 3.5) {
      return 'Junior Kickers';
    } else if (ageInYears >= 3.5 && ageInYears < 5.0) {
      return 'Mighty Kickers';
    } else if (ageInYears >= 5.0 && ageInYears <= 8.0) {
      return 'Mega Kickers';
    } else {
      // Return null or default value for children outside the valid range
      return 'Invalid Age Group';
    }
  }

  /// Determines if a child is eligible for a specific age group
  static bool isEligibleForAgeGroup(double ageInYears, String ageGroup) {
    switch (ageGroup) {
      case 'Little Kicks':
        return ageInYears >= 1.5 && ageInYears < 2.5;
      case 'Junior Kickers':
        return ageInYears >= 2.5 && ageInYears < 3.5;
      case 'Mighty Kickers':
        return ageInYears >= 3.5 && ageInYears < 5.0;
      case 'Mega Kickers':
        return ageInYears >= 5.0 && ageInYears <= 8.0;
      default:
        return false;
    }
  }
}