     
# Jobby
  
Jobby is a job searching and posting application built with Flutter, designed specifically for any job market(by changing the currency of job posting fees). It allows job seekers to find and apply for jobs, and employers to post and manage job listings, all in one place. 
  
## Features  

- [ ]User authentication (job seekers & employers) 
- [ ]Browse, search, and filter job listings
- [ ]Apply for jobs with cover letter and resume
- [ ]Save jobs for later
- [ ]Employer dashboard to post and manage jobs 
- [ ]Real-time notifications
- [ ]User profiles and job preferences
- [ ]Firebase integration (Auth, Firestore, Storage, Analytics)
- [ ]Mobile ads integration

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- A Firebase project (see below)
- Google Cloud/ Apple Auth Modules

### Setup
1. Clone this repository:
	```sh
	git clone https://github.com/yourusername/jobby.git
	cd jobby
	```
2. Install dependencies:
	```sh
	flutter pub get
	```
3. Configure Firebase:
	- Follow the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/) to set up Firebase for Android, iOS, and web.
	- Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the appropriate directories.
	- Update `lib/src/core/config/firebase_options.dart` if needed.
4. Run the app:
	```sh
	flutter run
	```

## Project Structure

- `lib/` - Main Dart source code
  - `src/features/` - App features (auth, job, profile, etc.)
  - `src/core/` - Core utilities, theme, routing, config
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` - Platform-specific code
- `test/` - Unit and widget tests

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes .

## License

This project is licensed under the MIT License.
