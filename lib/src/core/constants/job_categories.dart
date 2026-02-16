class JobCategory {
  final String id;
  final String name;
  final String icon;

  const JobCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class JobCategories {
  static const categories = [
    JobCategory(id: 'tech', name: 'Technology', icon: '💻'),
    JobCategory(id: 'healthcare', name: 'Healthcare', icon: '🏥'),
    JobCategory(id: 'education', name: 'Education', icon: '📚'),
    JobCategory(id: 'finance', name: 'Finance', icon: '💰'),
    JobCategory(id: 'retail', name: 'Retail', icon: '🛍️'),
    JobCategory(id: 'hospitality', name: 'Hospitality', icon: '🏨'),
    JobCategory(id: 'manufacturing', name: 'Manufacturing', icon: '🏭'),
    JobCategory(id: 'construction', name: 'Construction', icon: '🏗️'),
    JobCategory(id: 'transport', name: 'Transport & Logistics', icon: '🚚'),
    JobCategory(id: 'agriculture', name: 'Agriculture', icon: '🌾'),
    JobCategory(id: 'energy', name: 'Energy', icon: '⚡'),
    JobCategory(id: 'media', name: 'Media & Communication', icon: '📱'),
    // New categories
    JobCategory(id: 'beauty', name: 'Beauty & Wellness', icon: '💅'),
    JobCategory(id: 'food', name: 'Food & Restaurant', icon: '🍽️'),
    JobCategory(id: 'cleaning', name: 'Cleaning & Maintenance', icon: '🧹'),
    JobCategory(id: 'security', name: 'Security', icon: '🔒'),
    JobCategory(id: 'sales', name: 'Sales & Marketing', icon: '📢'),
    JobCategory(id: 'administrative', name: 'Administrative', icon: '📋'),
    JobCategory(id: 'customer_service', name: 'Customer Service', icon: '🤝'),
    JobCategory(id: 'automotive', name: 'Automotive', icon: '🚗'),
    JobCategory(id: 'real_estate', name: 'Real Estate', icon: '🏠'),
    JobCategory(id: 'telecom', name: 'Telecommunications', icon: '📡'),
    JobCategory(id: 'fashion', name: 'Fashion & Apparel', icon: '👕'),
    JobCategory(id: 'sports', name: 'Sports & Recreation', icon: '⚽'),
    JobCategory(id: 'arts', name: 'Arts & Entertainment', icon: '🎨'),
    JobCategory(id: 'legal', name: 'Legal Services', icon: '⚖️'),
    JobCategory(id: 'pharmacy', name: 'Pharmacy', icon: '💊'),
    JobCategory(id: 'insurance', name: 'Insurance', icon: '📄'),
    JobCategory(id: 'environment', name: 'Environmental Services', icon: '🌿'),
    JobCategory(id: 'electronics', name: 'Electronics Repair', icon: '🔧'),
    JobCategory(id: 'education_support', name: 'Education Support', icon: '✏️'),
    JobCategory(id: 'warehousing', name: 'Warehousing', icon: '📦'),
    JobCategory(id: 'freelance', name: 'Freelance & Gig Work', icon: '🆓'),
    JobCategory(id: 'human_resources', name: 'Human Resources', icon: '👥'),
    JobCategory(id: 'social_services', name: 'Social Services', icon: '🤲'),
    JobCategory(id: 'tourism', name: 'Tourism & Travel', icon: '✈️'),
  ];

  static JobCategory? getById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static const List<String> categoriesList = [
    'Software Development',
    'Design',
    'Marketing',
    'Sales',
    'Customer Service',
    'Finance',
    'Healthcare',
    'Education',
    'Engineering',
    'Human Resources',
    'Management',
    'Operations',
    'Administration',
    'Legal',
    'Consulting',
    'Research',
    'Other'
  ];

  static const List<String> commonLocations = [
    'Remote',
    'Douala',
    'Yaoundé',
    'Buea',
    'Bafoussam',
    'Ngaoundere',
    'Bertoua',
    'Bamenda',
    'Maroua',   
  ];
}