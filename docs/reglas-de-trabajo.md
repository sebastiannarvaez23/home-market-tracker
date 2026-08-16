# Reglas de trabajo — home-market-tracker

Estas reglas son vinculantes para cualquier desarrollo. Si una solución no las cumple, no se implementa.

## 1. Clean Architecture

La aplicación se parte en tres capas por feature. Las dependencias solo apuntan hacia adentro.

```
presentation  →  domain  ←  data
```

| Capa | Contiene | Prohibido |
| --- | --- | --- |
| `domain` | Entidades, value objects, contratos de repositorio, use cases | Flutter, SQLite, JSON, GetIt, rutas |
| `data` | Models, datasources, implementaciones, mapeo Model↔Entity | Widgets, BLoC, reglas de negocio nuevas |
| `presentation` | BLoC/Cubit, páginas, widgets de feature | SQL, models de data, cálculos de negocio |

- Un use case representa **una** acción de negocio.
- El domain no lanza excepciones de infraestructura. Usa `Result<Failure, T>`.
- El composition root (`lib/app/`) es el único lugar que conecta implementaciones concretas con abstracciones.

## 2. SOLID

- **S:** widget ≠ BLoC ≠ use case ≠ repositorio ≠ datasource.
- **O:** funcionalidad nueva = clase nueva (use case, estrategia, KPI), no un `switch` creciente.
- **L:** toda implementación de un contrato respeta los mismos invariantes y tipos de `Failure`.
- **I:** un repositorio por feature/capacidad. Nada de `AppRepository` global.
- **D:** el domain declara repositorios; `data` los implementa. Presentation depende de use cases.

## 3. Buenas prácticas Flutter

- Widgets funcionales, `const` cuando aplique.
- Estado de pantalla con BLoC/Cubit. Sin lógica de negocio en la UI.
- Estados de UI explícitos: `initial`, `loading`, `empty`, `data`, `error`.
- Entidades, eventos y estados inmutables y comparables.
- Archivos `snake_case.dart`. Domain 100% testeable sin `flutter_test` de widgets.
- No usar `BuildContext` después de un `await` sin verificar `context.mounted`.

## 4. Widgets encapsulados

Fuera de `lib/core/widgets/` **no** se usan widgets nativos de Material/Cupertino (`Text`, `TextField`, `ElevatedButton`, `Scaffold`, `AppBar`, `ListTile`, `Chip`, `Card`, `FloatingActionButton`, `SnackBar`, `AlertDialog`, `CircularProgressIndicator`, etc.).

Los features solo componen:

1. widgets del design system en `core/widgets`, o
2. widgets propios del feature, que a su vez solo usan `core/widgets`.

Excepción: `MaterialApp` y `ThemeData` en `lib/app/`.

Catálogo mínimo de core (cuando exista UI): `AppScaffold`, `AppAppBar`, `AppText`, `AppPriceText`, `AppTotalBadge`, `AppButton`, `AppIconButton`, `AppFab`, `AppTextField`, `AppSearchField`, `AppList`, `AppListTile`, `AppCard`, `AppTag`, `AppEmpty`, `AppLoading`, `AppError`, `AppConfirmDialog`.

## 5. Estructura de directorios

```
lib/
  app/                 # DI, router, widget raíz
  core/                # reglas, config, widgets transversales, DB, errores, utilidades
    database/
    error/
    usecase/
    widgets/
    theme/
    constants/
    utils/
  features/
    products/
      domain/
        entities/
        repositories/
        usecases/
      data/
        models/
        datasources/
        repositories/
      presentation/
        bloc/
        pages/
        widgets/
    markets/           # misma forma
    shopping/
    history/
    dashboard/
```

Reglas de desacople:

- Un feature no importa `data` ni `presentation` de otro.
- El `domain` de un feature no importa el `domain` de otro.
- `core/` no conoce features.
- La composición entre features ocurre solo en `lib/app/`.
- Lecturas cruzadas (RF5, dashboard) se resuelven en el **datasource del feature lector** contra el esquema SQLite compartido, no importando repositorios ajenos.

## 6. SQLite y capa de datos

- Una base, una conexión, migraciones incrementales en `core/database`.
- `PRAGMA foreign_keys = ON` y `journal_mode = WAL`.
- Datasource ejecuta SQL. Repositorio mapea y traduce errores a `Failure`.
- Escrituras que tocan varias tablas van en transacción.
- Listados y KPIs se resuelven con SQL (proyección, índices, agregaciones). No cargar la BD entera a memoria.
- Soft delete. Historial con snapshots de nombre de producto y mercado.
- IDs UUID en texto. Fechas en epoch milisegundos. Dinero con 2 decimales en domain.

## Alcance actual

No se diseñan ni implementan pantallas hasta que se solicite explícitamente. El trabajo válido ahora es reglas, contratos de dominio y, cuando se pida, capas `domain` y `data`.
