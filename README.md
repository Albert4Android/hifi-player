# Hi-Fi Player

**Hi-Fi Player** to osobisty odtwarzacz muzyki na Androida z interfejsem inspirowanym klasycznym sprzętem Hi-Fi. Celem projektu jest stworzenie lekkiej i stabilnej aplikacji do odtwarzania lokalnej biblioteki muzycznej z minimalistycznym, ponadczasowym UI.

Aplikacja tworzona jest w **Flutter + Dart** i docelowo będzie rozwijana o funkcje audio klasy Hi-Fi, analizę sygnału i wygodne zarządzanie biblioteką.

---

## Aktualny status projektu

Projekt znajduje się w fazie aktywnego rozwoju.

Obecnie:

* Repozytorium i środowisko Flutter są poprawnie skonfigurowane
* Struktura aplikacji jest gotowa do dalszej rozbudowy
* Przygotowane fundamenty pod bibliotekę, odtwarzanie i UI

Sekcja będzie aktualizowana wraz z postępem prac.

---

## Główne założenia projektu

Projekt powstaje z myślą o:

* lokalnej bibliotece muzycznej (offline-first)
* prostocie i stabilności
* klasycznym designie inspirowanym sprzętem Hi-Fi
* braku reklam i zbędnych funkcji
* pełnej kontroli nad muzyką użytkownika

---

## Uruchomienie projektu lokalnie

### Wymagania

Przed uruchomieniem upewnij się, że masz zainstalowane:

* Flutter SDK
  https://docs.flutter.dev/get-started/install
* Android Studio lub VS Code z pluginami Flutter i Dart
* Emulator Androida lub podłączone urządzenie

### Instalacja i start

```bash
git clone https://github.com/ZadruzynskiDS/hifi-player.git
cd hifi-player
flutter pub get
flutter run
```

---

## Struktura projektu

Najważniejsze katalogi:

```
lib/        → kod źródłowy aplikacji
assets/     → grafiki, fonty i zasoby
android/    → konfiguracja Android
ios/        → konfiguracja iOS
macos/      → konfiguracja macOS
test/       → testy jednostkowe
```

Kod aplikacji będzie rozwijany głównie w katalogu **lib/**.

---

## Plan rozwoju

Planowane funkcje:

* Odtwarzanie lokalnych plików audio
* Biblioteka albumów i utworów
* Queue / playlisty
* Shuffle i repeat
* Ekran Now Playing
* Analizator poziomu audio (VU Meter)
* Klasyczny interfejs Hi-Fi
* Obsługa formatów hi-res (FLAC, WAV, itp.)

---

## Licencja

Informacja o licencji zostanie dodana w późniejszym etapie projektu.

---

## Autor

Projekt tworzony jako osobisty Hi-Fi player do codziennego użytku i nauki Fluttera.
