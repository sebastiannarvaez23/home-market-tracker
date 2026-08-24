# Home Market Tracker

App **Flutter** para administrar las compras del mercado del hogar: catálogo de productos frecuentes, mercados, sesión de compra en curso, historial y un dashboard de eficiencia.

> Arquitectura estricta (Clean Architecture + SOLID), persistencia local en **SQLite** y UI solo a través del design system de `core/widgets`.

---

## Qué resuelve

| Feature | Responsabilidad |
| --- | --- |
| `products` | Catálogo frecuente, foto obligatoria al crear, escalera de UoM, última compra, sugeridos |
| `markets` | Establecimientos donde se compra (alta, edición, soft delete) |
| `shopping` | Una sesión `inProgress`: mercado, ítems, total y cierre |
| `history` | Consulta de compras completadas (solo lectura) |
| `dashboard` | KPIs del mes: gasto, ticket, eficiencia, sobreprecios, tendencia |

Todo corre **offline**, en un solo archivo SQLite del dispositivo. Sin auth, sin sync, un usuario local.

---

## Requisitos

- Flutter SDK **≥ 3.5** (Dart 3.5+)
- Un target nativo generado (`android/`, `ios/`, `windows/`, …)

Si clonaste el repo sin carpetas nativas:

```bash
flutter create . --project-name home_market_tracker
```

---

## Instalación

### 1. Dependencias

```bash
flutter pub get
```

### 2. Ejecutar

```bash
flutter run
```

Elige el dispositivo (emulador Android, Windows, etc.). La base se crea sola en el directorio de documentos de la app (`home_market_tracker.db`). No hay `.env` ni servidor.

### 3. Analizar

```bash
dart analyze
```

---

## Generar e instalar (Android e iOS)

Uso personal: no hace falta Play Store ni App Store. La versión sale de `pubspec.yaml` (hoy `0.2.0+2`).

Antes de empaquetar:

```bash
flutter pub get
```

### Android — APK

Se puede generar en **Windows, macOS o Linux**.

```bash
flutter build apk --release
```

El instalable queda en:

```
build/app/outputs/flutter-apk/app-release.apk
```

Cópialo al teléfono y ábrelo (hay que permitir instalar apps de orígenes desconocidos). Con el dispositivo conectado por USB:

```bash
flutter install --release
```

| Comando | Resultado |
| --- | --- |
| `flutter build apk --release` | Un APK con todas las arquitecturas. El más simple de pasar a alguien. |
| `flutter build apk --split-per-abi` | Un APK por ABI (más livianos). |
| `flutter build appbundle --release` | `.aab` para Play Store. No se instala a mano. |

Hoy el release **firma con la key de debug** (`android/app/build.gradle.kts`). Sirve para tu teléfono. Para publicar en Play Store hace falta un keystore propio.

### iOS — iPhone (no es APK)

iOS no usa APK. El paquete es un **`.ipa`**. **No se puede generar ni instalar desde Windows**: hace falta un **Mac con Xcode**.

Para usarla **solo en tu iPhone**:

1. Copia el repo al Mac (`git clone` o un zip).
2. Instala Xcode desde el App Store del Mac y ábrelo una vez (acepta licencias).
3. En la carpeta del proyecto:

```bash
flutter pub get
open ios/Runner.xcworkspace
```

4. En Xcode, target **Runner** → **Signing & Capabilities**:
   - Marca *Automatically manage signing*.
   - **Team**: tu Apple ID (Xcode → Settings → Accounts → + si no aparece).
   - Si el Bundle ID `com.example.home_market_tracker` choca, cámbialo a uno único (p. ej. `com.tuapellido.homemarkettracker`).
5. Enchufa el iPhone, desbloquéalo y confía en el Mac.
6. En el iPhone: **Ajustes → General → VPN y gestión de dispositivos** (o *Privacidad y seguridad*) → tu desarrollador → **Confiar**.
7. Instala:

```bash
flutter devices
flutter run --release
```

Elige el iPhone. La app queda en el escritorio como cualquier otra.

Para generar el `.ipa` (mismo Mac, ya firmado):

```bash
flutter build ipa --release
```

Sale en `build/ios/ipa/`.

Con Apple ID **gratis** el perfil dura **7 días**; hay que volver a instalar. Con cuenta de desarrollador de pago (99 USD/año) dura un año y puedes usar TestFlight.

---

## Tests

```bash
flutter test
```

- Domain y use cases: fakes en memoria (`test/helpers/fakes.dart`), sin Flutter.
- BLoC: `bloc_test`.
- Persistencia: tests SQLite de integración donde aplica (última compra, historial).

---

## Fuente de verdad

Antes de implementar cualquier cambio, leer en este orden:

| Documento | Qué define |
| --- | --- |
| [Reglas de trabajo](docs/reglas-de-trabajo.md) | Capas, SOLID, widgets encapsulados, estructura por feature |
| [Lógica de negocio](docs/logica-de-negocio.md) | Invariantes, use cases, KPIs, esquema SQLite |

Si una solución no cumple esos docs, no se implementa. No se inventan campos, pantallas ni indicadores.

Reglas equivalentes para el agente: `.cursor/rules/`.

---

## Arquitectura

Dependencias solo hacia adentro:

```
presentation  →  domain  ←  data
```

```
lib/
  app/                 # composition root: DI, shell, MaterialApp
  core/                # DB, Failure, use case base, theme, widgets
  features/
    products|markets|shopping|history|dashboard/
      domain/          # entidades, contratos, use cases
      data/            # models, datasource SQLite, repository impl
      presentation/    # Cubit, pages, widgets del feature
```

- Un use case = una acción (`CreateProduct`, `CompleteShopping`, `SuggestProduct`).
- Salida: `Result<Failure, T>`. El domain no lanza excepciones de infraestructura.
- Features no se importan entre sí. La composición vive en `lib/app/`.
- Material/Cupertino nativos **solo** en `lib/core/widgets/`.

---

## Persistencia

Una base, una conexión (`lib/core/database`). Migraciones incrementales en `lib/core/database/migrations/` (hoy schema **v6**).

| Regla | Cómo |
| --- | --- |
| Foreign keys | `PRAGMA foreign_keys = ON` |
| WAL | `journal_mode = WAL` |
| IDs | `TEXT` UUID |
| Fechas | `INTEGER` epoch ms |
| Banderas | `INTEGER` 0/1 (`is_active`, `is_suggested`) |
| Dinero | `REAL` en SQLite; `Money` (centavos) en domain |

El `.db` **no** va al repo. Se crea en runtime (Documentos de la app o sandbox Android). Junto a él pueden aparecer `-wal` / `-shm`.

---

## Flujo de compra (resumen)

1. **Mercar** en el home → elegir o crear mercado.
2. Catálogo: sugeridos primero (divisor rojo), luego el resto. Filtro por nombre.
3. Al agregar: precio (solo dígitos, máscara `$ 1'500.000`), cantidad y UoM de la escalera del producto.
4. El total lo calcula el domain y se muestra arriba a la derecha.
5. **Terminar mercado** pasa la sesión a historial y quita la marca de sugerido de lo comprado. **Descartar** cancela sin historial. Volver atrás deja la sesión `inProgress`.

---

## Stack

| Pieza | Uso |
| --- | --- |
| Flutter + Dart 3.5 | UI y domain |
| flutter_bloc / Cubit | Estado de pantalla |
| get_it | DI solo en `lib/app/` |
| sqflite (+ FFI en desktop) | SQLite |
| equatable | Comparación de entidades y estados |
| google_fonts | Tipografía (Poppins) |
| image_picker | Cámara al crear un producto |

---

## Buenas prácticas que este repo exige

- Separación por capas y por feature (no un `AppRepository` dios)
- Use cases pequeños, testeables sin widgets
- Escrituras multi-tabla en `transaction` (completar compra, reemplazar ítems)
- Listados con proyección de columnas; agregaciones en SQL (RF5, dashboard)
- Historial inmutable (snapshots de nombre de producto y mercado)
- Soft delete: no se borran filas referenciadas por compras pasadas

---

Si vas a contribuir, sigue `docs/reglas-de-trabajo.md` y no desvíes el esquema ni los use cases de `docs/logica-de-negocio.md`.
