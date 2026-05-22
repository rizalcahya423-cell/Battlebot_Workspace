# Flutter Project Rules — AI Agent Guidelines

> Aturan ini wajib diikuti oleh AI Agent saat membuat, memodifikasi, atau me-review kode Flutter.
> Tujuan: menghasilkan kode yang bersih, efisien, maintainable, dan profesional.

---

## 1. Struktur Folder

```
lib/
├── core/
│   ├── constants/        # AppColors, AppSizes, AppStrings, AppRoutes
│   ├── errors/           # Failure, Exception classes
│   ├── extensions/       # Extension methods (BuildContext, String, DateTime, dll)
│   ├── theme/            # AppTheme, TextStyles
│   ├── utils/            # Helper functions (formatter, validator, dll)
│   └── widgets/          # Shared/reusable widgets
│
├── data/
│   ├── datasources/      # Remote (API) & Local (DB/cache) datasources
│   ├── models/           # Data models + fromJson/toJson
│   └── repositories/     # Implementasi repository
│
├── domain/
│   ├── entities/         # Pure business objects (tanpa dependency framework)
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Satu file per use case
│
├── features/
│   └── <feature_name>/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── bloc/     # (atau provider/, riverpod/, cubit/)
│           ├── pages/
│           └── widgets/  # Widget khusus fitur ini
│
├── l10n/                 # Lokalisasi (jika ada)
└── main.dart
```

**Aturan:**
- Satu file = satu class/widget utama
- Nama file: `snake_case.dart`
- Nama class: `PascalCase`
- Tidak ada file `utils.dart` atau `helpers.dart` yang berisi semua hal — pisah per domain
- Feature-first untuk fitur besar; shared logic ke `core/`

---

## 2. Penamaan (Naming Conventions)

| Entitas | Konvensi | Contoh |
|---|---|---|
| File & folder | `snake_case` | `user_profile_page.dart` |
| Class, Enum, Typedef | `PascalCase` | `UserProfile`, `AuthState` |
| Variable, function, parameter | `camelCase` | `userName`, `fetchUser()` |
| Konstanta | `camelCase` (Dart idiom) | `maxRetryCount` |
| Private member | `_camelCase` | `_isLoading` |
| Extension | `PascalCase` + konteks | `StringExtension`, `ContextExtension` |

**Aturan:**
- Nama harus deskriptif — jangan: `data`, `temp`, `val`, `x`, `item2`
- Boolean: gunakan prefix `is`, `has`, `can`, `should` — contoh: `isLoading`, `hasError`
- Fungsi: gunakan kata kerja — contoh: `fetchUser()`, `parseDate()`, `validateEmail()`
- Jangan singkat nama kecuali konvensi umum (`ctx`, `e`, `i` dalam loop)

---

## 3. Widget & UI

### 3.1 Pemisahan Widget

```dart
// ✅ BENAR — pisah widget kecil
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _UserAvatar(url: user.avatarUrl),
          _UserInfo(name: user.name, email: user.email),
        ],
      ),
    );
  }
}

// ❌ SALAH — satu build() yang panjang dengan ratusan baris
```

**Aturan:**
- `build()` tidak boleh lebih dari **50 baris**; jika lebih, pecah menjadi widget terpisah
- Gunakan `const` constructor di mana pun memungkinkan
- Hindari logic bisnis di dalam widget — delegasikan ke controller/bloc/provider
- Jangan panggil fungsi async langsung di `build()`

### 3.2 Hindari Rebuild Tidak Perlu

```dart
// ✅ BENAR
const SizedBox(height: 16)
const Text('Label', style: TextStyle(fontSize: 14))

// ❌ SALAH — membuat object baru setiap build
SizedBox(height: 16)
Text('Label', style: TextStyle(fontSize: 14))
```

- Selalu pakai `const` untuk widget yang tidak bergantung pada data runtime
- Gunakan `Selector` / `select()` / `watch` spesifik, bukan `watch` seluruh state

### 3.3 Layout

- Gunakan `Spacer` dan `SizedBox` — jangan `Padding` berulang yang bisa digabung
- Hindari `Column` di dalam `Column` yang tidak perlu — pertimbangkan `ListView` atau `Sliver`
- Jangan hardcode ukuran piksel; gunakan konstanta dari `AppSizes` atau `MediaQuery`

---

## 4. State Management

- Pilih **satu** pendekatan state management per project (Bloc/Cubit, Riverpod, atau Provider) — jangan campur
- State immutable: gunakan `copyWith()` untuk update, bukan mutasi langsung
- Pisahkan state loading/success/error secara eksplisit:

```dart
// ✅ BENAR
sealed class UserState {
  const UserState();
}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  const UserLoaded(this.user);
  final User user;
}
class UserError extends UserState {
  const UserError(this.message);
  final String message;
}
```

- Jangan simpan `BuildContext` di dalam Bloc/Cubit/Controller
- Dispose controller/subscription dengan benar di `close()` / `dispose()`

---

## 5. Kode Bersih & Efisien

### 5.1 Tidak Ada Kode Mati (Dead Code)

- Hapus semua `import` yang tidak dipakai (jalankan `dart fix --apply` atau aktifkan lint rule)
- Hapus semua fungsi, variable, dan widget yang tidak pernah dipanggil
- Hapus semua `print()` dan `debugPrint()` sebelum commit (gunakan logger yang proper)
- Hapus semua komentar kode yang di-comment-out (`// old code here`)

### 5.2 Tidak Ada Duplikasi (DRY)

```dart
// ❌ SALAH — duplikasi logika
if (response.statusCode == 401) { logout(); }
// ... di file lain ...
if (response.statusCode == 401) { logout(); }

// ✅ BENAR — centralize di interceptor atau error handler
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) logout();
    super.onError(err, handler);
  }
}
```

- Logika yang dipakai 2+ kali **wajib** diekstrak ke fungsi/widget/extension
- UI padding/spacing yang berulang masuk ke `AppSizes` konstanta
- Warna dan style masuk ke `AppTheme` / `AppColors`

### 5.3 Fungsi & Method

- Satu fungsi = satu tanggung jawab (Single Responsibility)
- Maksimal **20–30 baris** per fungsi; jika lebih, refactor
- Hindari parameter boolean flag — buat fungsi terpisah:

```dart
// ❌ SALAH
void showDialog(bool isError) { ... }

// ✅ BENAR
void showErrorDialog() { ... }
void showSuccessDialog() { ... }
```

- Gunakan named parameters untuk fungsi dengan 3+ parameter:

```dart
// ✅
void createUser({
  required String name,
  required String email,
  String? phone,
})
```

---

## 6. Null Safety & Error Handling

- **Tidak boleh** menggunakan `!` (null assertion) tanpa pengecekan eksplisit di atasnya
- Gunakan `??`, `?.`, dan `if (x != null)` dengan benar
- Semua error dari network/database **wajib** di-handle — jangan biarkan `try-catch` kosong:

```dart
// ❌ SALAH
try {
  await fetchData();
} catch (e) {}

// ✅ BENAR
try {
  await fetchData();
} catch (e, stackTrace) {
  logger.error('fetchData failed', error: e, stackTrace: stackTrace);
  emit(UserError(e.toString()));
}
```

- Gunakan `Either<Failure, T>` (atau `Result<T>`) untuk return type fungsi yang bisa gagal
- Jangan `throw` di dalam widget `build()`

---

## 7. Performa

- **Lazy load** list panjang dengan `ListView.builder`, bukan `ListView` dengan children statis
- Gunakan `RepaintBoundary` untuk widget animasi yang sering repaint
- Image: selalu tentukan `width`, `height`, dan gunakan `cacheWidth`/`cacheHeight` bila perlu
- Hindari `setState` yang men-trigger rebuild area luas — isolasi state ke widget terkecil yang perlu update
- Gunakan `compute()` untuk komputasi berat (JSON parsing besar, enkripsi, dll)

```dart
// ✅ Parse JSON besar di isolate terpisah
final users = await compute(_parseUsers, jsonString);
```

---

## 8. Dependency Injection

- Gunakan DI (GetIt, Riverpod, Injectable, dll) — jangan instansiasi service langsung di widget
- Daftarkan semua dependency di satu tempat (`injection_container.dart` / `providers.dart`)
- Gunakan `singleton` untuk service yang stateful (AuthService, ApiClient); `factory` untuk use case

---

## 9. Model & Serialisasi

- Model wajib punya `fromJson`, `toJson`, dan `copyWith`
- Gunakan code generation (`freezed`, `json_serializable`) untuk model kompleks — jangan tulis manual
- Pisahkan **entity** (domain layer, pure Dart) dan **model** (data layer, dengan serialisasi)
- Jangan kirim entity langsung ke API — konversi ke model dulu

---

## 10. Navigasi

- Gunakan named routes atau router package (`go_router`, `auto_route`) — jangan `Navigator.push` dengan `MaterialPageRoute` tersebar di mana-mana
- Definisikan semua route name di `AppRoutes` konstanta
- Hindari passing `BuildContext` melewati batas async — cek `mounted` sebelum pakai context:

```dart
// ✅
await doSomething();
if (!mounted) return;
Navigator.of(context).pop();
```

---

## 11. Testing

- Setiap use case **wajib** memiliki unit test
- Widget kompleks wajib memiliki widget test
- Gunakan mock (`mocktail` atau `mockito`) — jangan hit API sungguhan di test
- Nama test: deskriptif dengan pola `should_[expected]_when_[condition]`

```dart
test('should return User when fetchUser is called with valid id', () async { ... });
```

---

## 12. Linting & Formatting

Tambahkan ke `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_use_package_imports
    - avoid_print
    - avoid_relative_lib_imports
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - sized_box_for_whitespace
    - use_build_context_synchronously

analyzer:
  errors:
    unused_import: error
    unused_local_variable: error
    dead_code: error
```

- Jalankan `dart format .` sebelum setiap commit
- Jalankan `flutter analyze` dan pastikan **0 warning, 0 error**
- Aktifkan pre-commit hook untuk otomatisasi di atas

---

## 13. Git & Commit

- Satu commit = satu perubahan logis
- Format pesan commit: `type(scope): deskripsi singkat`
  - `feat(auth): add biometric login`
  - `fix(home): resolve null crash on empty list`
  - `refactor(user): extract UserCard widget`
  - `chore: update dependencies`
- Jangan commit file: `.env`, `*.g.dart` (jika tidak di-track), `build/`, `.dart_tool/`

---

## 14. Checklist Sebelum PR / Selesai Coding

- [ ] Tidak ada `unused import`
- [ ] Tidak ada `print()` atau kode debug
- [ ] Tidak ada kode yang di-comment-out
- [ ] Semua widget menggunakan `const` di mana memungkinkan
- [ ] Tidak ada magic number — semua pakai konstanta
- [ ] Error handling lengkap (tidak ada try-catch kosong)
- [ ] `flutter analyze` = 0 issue
- [ ] `dart format .` sudah dijalankan
- [ ] Test untuk logic baru sudah ditulis
- [ ] Nama variable/fungsi/class sudah deskriptif
