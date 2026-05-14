# Cucine in città

Micro-app Flutter per esplorare le cucine disponibili in ogni città, usando le API pubbliche di BestieBite.

---

## Come runnarlo

```bash
# 1. Installa le dipendenze
flutter pub get

# 2. Avvia (scegli il target)
flutter run -d chrome          # Web — setup zero, consigliato per provarlo subito
flutter run -d ios             # iOS Simulator (macOS + Xcode richiesti)
flutter run -d android         # Android Emulator
```

**Requisiti:** Flutter SDK ≥ 3.3.0 · Dart ≥ 3.3.0 · connessione internet (API live)

### Test unitari

```bash
flutter test test/city_repository_test.dart
```

---

## Architettura

- **Layer separati** — `domain` (entità + interfaccia repository), `data` (DTO + implementazione HTTP), `presentation` (BLoC + UI); le dipendenze puntano sempre verso il basso
- **BLoC** come state management: eventi espliciti (`SearchTermChanged`, `CitySelected`, `BackToSearch`, `RetryRequested`) mappati su un unico `CityState` immutabile con due sezioni (ricerca / cucine)
- **Debounce via rxdart** applicato come `transformer` nell'`on<SearchTermChanged>`, con `switchMap` che annulla le chiamate in volo se l'utente continua a digitare
- **Repository iniettato** — `BestieBiteRepository` accetta un `http.Client` come parametro opzionale, rendendo i test unitari possibili senza infrastruttura aggiuntiva
- **Un'unica pagina** con `AnimatedSwitcher` tra vista ricerca e vista cucine; nessun `Navigator.push`, zero gestione dello stack

---

## Una cosa di cui sono orgoglioso

Il modo in cui debounce e cancellazione delle chiamate in volo sono gestiti in tre righe dentro il BLoC, senza nessun `Timer` manuale o `StreamController` esplicito:

```dart
on<SearchTermChanged>(
  _onSearchTermChanged,
  transformer: (events, mapper) => events
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap(mapper),
);
```

È la soluzione più pulita che conosco per questo problema in Flutter: dichiarativa, testabile, e non lascia nulla in sospeso se il widget viene dismesso.

---

## Una cosa che farei diversamente con più tempo

Introdurrei **`bloc_test`** per testare il BLoC stesso, non solo il repository. I test attuali verificano il parsing dei DTO e il comportamento HTTP, ma non coprono le transizioni di stato. Con `bloc_test` si scrive in modo molto leggibile:

```dart
blocTest<CityBloc, CityState>(
  'emits [searching, suggestions] when term is valid',
  build: () => CityBloc(mockRepository),
  act: (bloc) => bloc.add(const SearchTermChanged('mila')),
  expect: () => [
    isA<CityState>().having((s) => s.searchPhase, 'phase', SearchPhase.searching),
    isA<CityState>().having((s) => s.searchPhase, 'phase', SearchPhase.suggestions),
  ],
);
```

Avrebbe reso più sicuro qualsiasi refactor del BLoC nel corso dello sviluppo.