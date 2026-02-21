# Hi-Fi Player (Android)

Hi-Fi Player to osobisty odtwarzacz muzyki na Androida inspirowany klasycznym sprzętem Hi-Fi.
Projekt skupia się na prostocie, stabilności i pełnej kontroli nad lokalną biblioteką muzyczną bez reklam i zbędnych funkcji.

Aplikacja tworzona jest w **Flutter + Dart** i rozwijana jako Android-only.

---

## Status projektu

Projekt znajduje się w aktywnym rozwoju.

Obecnie:

* działająca struktura aplikacji Flutter
* biblioteka albumów z MediaStore
* mini-player
* ekran Now Playing
* fundament pod VU Meter i dalszy rozwój audio

---

## Założenia projektu

Główne cele:

* odtwarzanie lokalnej biblioteki (offline-first)
* klasyczny, ponadczasowy interfejs Hi-Fi
* brak reklam i zbędnych usług sieciowych
* lekka i szybka aplikacja
* pełna kontrola nad plikami użytkownika

---

## Uruchomienie projektu lokalnie

### Wymagania

* Flutter SDK
  https://docs.flutter.dev/get-started/install
* Android Studio lub VS Code z pluginami Flutter i Dart
* Emulator Androida lub fizyczne urządzenie

### Instalacja

```bash
git clone https://github.com/Albert4Android/hifi-player.git
cd hifi-player
flutter pub get
flutter run
```

---

## Struktura projektu

```
android/   → konfiguracja Android
lib/       → kod aplikacji
assets/    → grafiki i zasoby
test/      → testy Flutter
```

Najważniejsze moduły w `lib/`:

* `audio/` – silnik odtwarzacza i logika audio
* `features/` – ekrany aplikacji (Library, Player)
* `widgets/` – współdzielone komponenty UI
* `services/` – VU meter i logika pomocnicza
* `ui/` – motyw aplikacji

---

## Plan rozwoju

Planowane funkcje:

* kolejka odtwarzania i playlisty
* shuffle / repeat
* pełny ekran Now Playing
* analogowy VU Meter
* obsługa formatów hi-res (FLAC, WAV)

---

## Licencja

Informacja o licencji zostanie dodana w późniejszym etapie projektu.

---

## Autor

Projekt tworzony jako osobisty odtwarzacz Hi-Fi do codziennego użytku i nauki Fluttera.
