# KotobaMate - Japanese Vocabulary Learning App

KotobaMate is a Flutter-based mobile application designed to help users learn Japanese vocabulary effectively through interactive flashcards and spaced repetition learning techniques.

## Features

- 📱 Interactive flip cards for vocabulary learning
- 🔄 Bi-directional learning (Japanese to Vietnamese and vice versa)
- 🔊 Text-to-speech functionality for Japanese pronunciation
- 📂 Organize vocabulary by folders
- 🔀 Shuffle feature for randomized learning
- 👆 Intuitive swipe gestures for card navigation

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- A physical device or emulator for testing
- Japanese language pack installed on your device (required for text-to-speech functionality)

### Language Requirements

For the text-to-speech feature to work properly:
- Ensure Japanese language support is installed on your device
- The device's text-to-speech engine must support Japanese (ja-JP)
- If using Android, install Japanese language pack from device settings
- If using iOS, ensure Japanese is available in Siri voices

### Installation

1. Clone the repository:
```bash
git clone https://github.com/TranPhucTin/kotobamate.git
```

2. Navigate to the project directory:
```bash
cd kotobamate
```

3. Install dependencies:
```bash
flutter pub get
```

4. Create a `.env` file in the root directory and add your API keys:
```
TTS_API_KEY=your_api_key_here
```

5. Run the app:
```bash
flutter run
```

## Environment Setup

1. Copy the `.env.example` file to create a new `.env` file:
```bash
cp .env.example .env
```

2. Update the `.env` file with your actual API keys

## Architecture

The project follows Clean Architecture principles with the following layers:
- Presentation (UI/Widgets)
- Domain (Business Logic)
- Data (Repository/Data Sources)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter Team for the amazing framework
- Contributors and supporters of the project
