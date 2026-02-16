class OnboardingItem {
  final String title;
  final String description;
  final String image;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Find Your Dream Job',
      description: 'Discover thousands of job opportunities with all the information you need.',
      image: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      title: 'Easy Job Posting',
      description: 'Post job openings and find the perfect candidates for your company.',
      image: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      title: 'Quick Application',
      description: 'Apply to jobs with just a few taps and track your applications easily.',
      image: 'assets/images/onboarding_3.png',
    ),
  ];
}