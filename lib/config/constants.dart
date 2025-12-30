/// App-wide constants for Boldask.

class AppConstants {
  // App info
  static const String appName = 'Boldask';
  static const String appVersion = '1.0.0';
  static const String websiteUrl = 'https://boldask.com';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String pollsCollection = 'polls';
  static const String circlesCollection = 'circles';
  static const String projectsCollection = 'projects';
  static const String siteContentCollection = 'site_content';
  static const String newsCollection = 'news';
  static const String appConfigCollection = 'app_config';

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPollAnswers = 5;
  static const int maxTagsPerItem = 10;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Storage paths
  static const String profilePhotosPath = 'profile_photos';
  static const String contentImagesPath = 'content';
}

/// Tags for polls and circles categorization.
class TagCategories {
  static const List<String> personalGrowth = [
    'Physical Health',
    'Mental Health',
    'Spirituality',
    'Education',
    'Career Development',
    'Leadership',
    'Self-awareness',
    'Self-esteem',
    'Happiness',
    'Art',
    'Music',
    'Reading',
    'Writing',
    'Travel',
    'Relationships',
    'Family',
    'Friendship',
    'Communication',
    'Time Management',
    'Productivity',
    'Financial Literacy',
    'Mindfulness',
    'Meditation',
    'Exercise',
    'Nutrition',
    'Sleep',
    'Hobbies',
    'Creativity',
    'Goal Setting',
    'Personal Finance',
  ];

  static const List<String> socialPolitical = [
    'Social Norms',
    'Race',
    'Gender',
    'Politics',
    'Economy',
    'Environment',
    'Equality',
    'Freedom',
    'Justice',
    'Immigration',
    'Healthcare',
    'Education Policy',
    'Technology',
    'Privacy',
    'Media',
    'Democracy',
    'Human Rights',
    'Climate Change',
    'Poverty',
    'Housing',
    'Crime',
    'Labor Rights',
    'Trade',
    'Foreign Policy',
    'Military',
    'Religion in Society',
    'Free Speech',
    'Censorship',
    'Social Media',
    'Community',
  ];

  static List<String> getAllTags() {
    return [...personalGrowth, ...socialPolitical];
  }
}

/// Circle format options.
enum CircleFormat {
  online('Online'),
  inPerson('In-Person'),
  both('Both');

  final String label;
  const CircleFormat(this.label);
}

/// Sort options for lists.
enum SortOption {
  popular('Popular'),
  favorites('My Favorite'),
  newest('New'),
  following('Following');

  final String label;
  const SortOption(this.label);
}
