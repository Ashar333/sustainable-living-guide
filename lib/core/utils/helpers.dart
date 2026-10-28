import 'package:intl/intl.dart';

/// Utility class for input validations.
class Validators {
  /// Validates email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates confirm password match.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates required fields.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates phone number format.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates name length.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates message length.
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters';
    }
    return null;
  }
}

/// Utility class for date and number formatting.
class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatNumber(double number) {
    return NumberFormat('#,##0.00').format(number);
  }

  static String formatCO2(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(2)} tons';
    }
    return '${kg.toStringAsFixed(2)} kg';
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

/// Utility for carbon footprint calculations.
class CarbonCalculator {
  /// Calculate transport emissions.
  static double calculateTransport(String type, double distance) {
    const factors = {
      'car': 0.21,
      'bus': 0.089,
      'train': 0.041,
      'flight': 0.255,
      'bicycle': 0.0,
      'walking': 0.0,
    };
    return distance * (factors[type.toLowerCase()] ?? 0.21);
  }

  /// Calculate electricity emissions.
  static double calculateElectricity(double kwh) {
    return kwh * 0.42;
  }

  /// Calculate food emissions.
  static double calculateFood(String type, double kg) {
    const factors = {
      'beef': 27.0,
      'lamb': 39.2,
      'pork': 12.1,
      'poultry': 6.9,
      'fish': 6.1,
      'eggs': 4.8,
      'vegetables': 2.0,
      'fruits': 1.1,
      'grains': 1.4,
      'dairy': 3.2,
    };
    return kg * (factors[type.toLowerCase()] ?? 2.0);
  }

  /// Calculate water emissions.
  static double calculateWater(double liters) {
    return liters * 0.00034;
  }

  /// Calculate overall sustainability score (0-100).
  static int calculateScore(double totalEmissions, double baseline) {
    if (baseline == 0) return 100;
    final ratio = totalEmissions / baseline;
    if (ratio <= 0.3) return 95;
    if (ratio <= 0.5) return 85;
    if (ratio <= 0.7) return 70;
    if (ratio <= 1.0) return 55;
    if (ratio <= 1.5) return 35;
    return 15;
  }

  /// Get reduction suggestions based on emissions.
  static List<String> getSuggestions({
    required double transportEmissions,
    required double electricityEmissions,
    required double foodEmissions,
    required double waterEmissions,
  }) {
    final suggestions = <String>[];
    final total =
        transportEmissions + electricityEmissions + foodEmissions + waterEmissions;
    if (total == 0) return ['Start tracking your activities to get suggestions!'];

    if (transportEmissions / total > 0.3) {
      suggestions.addAll([
        'Try using public transport or cycling for short distances',
        'Consider carpooling with colleagues',
        'Plan your trips to combine multiple errands',
      ]);
    }
    if (electricityEmissions / total > 0.3) {
      suggestions.addAll([
        'Switch to LED bulbs to save up to 75% energy',
        'Unplug devices when not in use',
        'Use natural lighting during the day',
      ]);
    }
    if (foodEmissions / total > 0.3) {
      suggestions.addAll([
        'Try meatless Mondays to reduce food emissions',
        'Buy locally grown produce',
        'Reduce food waste by meal planning',
      ]);
    }
    if (waterEmissions / total > 0.2) {
      suggestions.addAll([
        'Fix leaking faucets to save water',
        'Take shorter showers',
        'Collect rainwater for gardening',
      ]);
    }
    if (suggestions.isEmpty) {
      suggestions.add('Great job! Keep up your sustainable habits!');
    }
    return suggestions;
  }
}
