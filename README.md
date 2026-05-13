# Cucine in città

Un'app Flutter per esplorare le cucine disponibili in ogni città, usando le API pubbliche di BestieBite.

---

## Screenshot dei flussi

| Idle | Suggerimenti | Cucine |
|------|-------------|--------|
| Mappa Italia + search bar | Lista città autocomplete | Griglia 3×N con emoji cucine |

---

## Come avviare

### Prerequisiti
- Flutter SDK ≥ 3.3.0  
- Dart ≥ 3.3.0  
- Un device/emulatore iOS, Android, o browser (Web)

### Setup
```bash
flutter pub get
```

### Run (Web — più veloce per testare)
```bash
flutter run -d chrome
```

### Run (iOS Simulator)
```bash
open -a Simulator
flutter run -d ios
```

### Run (Android Emulator)
```bash
flutter run -d android
```

---

## Test unitari

```bash
flutter test test/city_repository_test.dart
```

I test coprono:
- `CitySuggestionModel.fromJson` — parsing DTO
- `CuisineModel / CuisinesResponseModel.fromJson` — parsing DTO
- `BestieBiteRepository.autocomplete` — con mock HTTP (200, 403, term < 2 chars)
- `BestieBiteRepository.getCuisines` — con mock HTTP (200, 404)

---

## Architettura

```
lib/
├── data/
│   ├── models/           ← DTO (JSON → Dart, puri, testabili)
│   │   ├── city_suggestion_model.dart
│   │   └── cuisine_model.dart
│   └── repositories/
│       └── bestiebite_repository.dart  ← HTTP, mappatura → entity
├── domain/
│   ├── entities/         ← Oggetti di dominio (Equatable, no Flutter)
│   │   ├── city_suggestion.dart
│   │   └── cuisine.dart
│   └── repositories/
│       └── city_repository.dart  ← Interfaccia astratta
└── presentation/
    ├── bloc/
    │   ├── city_bloc.dart   ← Logica + debounce (rxdart)
    │   ├── city_event.dart
    │   └── city_state.dart
    ├── pages/
    │   └── home_page.dart   ← Una sola pagina, due "viste" animate
    ├── widgets/             ← Widget atomici riusabili
    └── app_theme.dart       ← Design tokens centralizzati
```

---

## Scelte tecniche

### State management: **flutter_bloc**
- Separazione netta eventi → stati; facile da testare con `bloc_test`
- `BlocBuilder` minimizza i rebuild (ascolta solo `CityState`)
- Alternativa valida: Riverpod (più boilerplate ridotto con code-gen, ma più magia implicita)

### Debounce: **rxdart** `debounceTime` via `transformer`
- Applicato direttamente nell'`on<SearchTermChanged>` senza overhead extra
- `switchMap` annulla le chiamate precedenti se l'utente digita ancora

### HTTP: **http** + **User-Agent custom**
- Header `BestieBite-Interview/1.0` come da specifica (evita 403 Cloudflare)
- `BestieBiteRepository` dipende da `http.Client` iniettato → testabile con `mocktail`

### Immagini: **cached_network_image**
- Cache su disco automatica per le PNG Firebase
- Placeholder + error fallback già gestiti

---

## Stati UI implementati

| Stato | Trigger |
|-------|---------|
| **Idle** | Campo vuoto |
| **Searching** | Spinner circolare durante debounce + fetch |
| **Suggestions** | Lista città in card arrotondata |
| **No results** | API ritorna `[]` |
| **Loading cuisines** | Dopo tap su città, spinner |
| **Cuisines shown** | Griglia 3 colonne |
| **Empty cuisines** | `data: []` dalla risposta |
| **Error** | Qualsiasi eccezione HTTP/network + bottone Riprova |
