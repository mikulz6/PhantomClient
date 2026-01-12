# Phantom Client

A commercial-grade cloud gaming client with high-end UI/UX, powered by Moonlight core.

## Project Structure

- `lib/`: Flutter frontend source code.
  - `features/`: Feature-based modules (Games, Lobby, etc.).
  - `core/`: Core utilities and Native Bridge.
- `android/`: Android host project.
- `origin_sdk/`: Contains the original Moonlight core source code (submodule).
  - `moonlight_core/Client-Android`: Reference Android implementation.
  - `moonlight_core/Client-PC`: Reference PC (Qt) implementation.
  - `moonlight_core/moonlight-common-c`: Common C libraries.
- `scripts/`: Utility scripts (Steam spider, Mock generator).
- `assets/`: Static assets (Images, JSON data).

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Python 3 (for scripts)

### Setup

1. Clone the repository with submodules:
   ```bash
   git clone --recursive <repo_url>
   ```
2. Generate mock data (optional):
   ```bash
   python3 scripts/generate_mock.py
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Windows Development

Currently in progress. Check `lib/features/games/presentation/desktop/` for upcoming Windows UI components.
