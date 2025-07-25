# AKER - Animal Rescue App 🐾

AKER is a comprehensive Flutter-based mobile application designed to facilitate animal rescue operations and connect animal lovers with rescue organizations. The app provides a platform for reporting animal emergencies, accessing rescue resources, and getting expert guidance through an AI-powered chatbot.

## Features ✨

###  Emergency Reporting
- Quick animal emergency reporting with location tracking
- Photo upload capability for better assessment
- Real-time status updates on rescue operations
- Emergency contact integration

### 🗺 Interactive Map
- View nearby animal rescue organizations
- Track reported animal cases in your area
- Find veterinary clinics and animal shelters
- GPS-based location services

###  AI-Powered Chatbot
- Get instant advice on animal care and first aid
- Emergency response guidance
- Connect with veterinary professionals
- 24/7 availability for urgent queries

###  User Management
- Secure user authentication
- Personal profile management
- Rescue history tracking
- Volunteer registration system

###  Reports Dashboard
- View all submitted reports
- Track rescue progress
- Access rescue statistics
- Generate rescue reports

## Technology Stack 

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **AI Integration**: OpenRouter API
- **Maps**: Google Maps API
- **State Management**: Provider/Riverpod
- **Storage**: Supabase Storage

## Prerequisites

Before running this project, make sure you have:

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Git
- A Supabase account and project
- OpenRouter API key
- Google Maps API key (for map functionality)

## Installation & Setup 

### 1. Clone the Repository
```bash
git clone https://github.com/geno543/AKER_APP.git
cd AKER
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the root directory and add your API keys:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENROUTER_API_KEY=your_openrouter_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 4. Database Setup
Run the SQL setup script in your Supabase dashboard:
```bash
# Execute the contents of supabase_setup.sql in your Supabase SQL editor
```

### 5. Run the Application
```bash
# For development
flutter run

# For release build
flutter build apk --release
```

## Project Structure 📁

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── animal_report_model.dart
│   ├── user_model.dart
│   └── user_profile_model.dart
├── screens/                  # UI screens
│   ├── auth_screen.dart
│   ├── chatbot_screen.dart
│   ├── emergency_tips_screen.dart
│   ├── home_screen.dart
│   ├── map_screen.dart
│   ├── profile_screen.dart
│   ├── report_screen.dart
│   └── reports_screen.dart
├── services/                 # API services
│   ├── openrouter_service.dart
│   └── supabase_service.dart
├── utils/                    # Utilities
│   └── app_theme.dart
└── widgets/                  # Reusable widgets
    ├── quick_action_button.dart
    └── rescue_card.dart
```

## Usage 

### Reporting an Animal Emergency
1. Open the app and navigate to the "Report" section
2. Fill in the animal details and location
3. Upload photos if available
4. Submit the report for immediate processing

### Using the AI Chatbot
1. Access the chatbot from the home screen
2. Ask questions about animal care or emergencies
3. Follow the provided guidance and recommendations

### Viewing Rescue Operations
1. Check the "Reports" section for all submissions
2. Use the map view to see nearby rescue activities
3. Track the status of your reported cases

## Contributing 

We welcome contributions to improve AKER! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License 

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Join our community discussions

**Made with ❤️ for animal welfare**
