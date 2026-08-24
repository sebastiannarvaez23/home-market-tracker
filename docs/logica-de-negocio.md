# Lógica de negocio — home-market-tracker

Aplicación móvil para administrar las compras del mercado del hogar. No describe pantallas: solo dominios, invariantes, casos de uso y persistencia.

## 1. Dominios

| Feature | Responsabilidad | Escritura |
| --- | --- | --- |
| `products` | Catálogo de productos frecuentes | CRUD lógico (soft delete) |
| `markets` | Establecimientos donde se compra | CRUD lógico (soft delete) |
| `shopping` | Compra en curso: mercado + ítems + total | Crear sesión, upsert/quitar ítems, completar, cancelar |
| `history` | Consulta de compras completadas | Solo lectura |
| `dashboard` | Indicadores de calidad de mercadeo | Solo lectura |

`history` y `dashboard` no poseen tablas propias. Leen `shopping_sessions` y `shopping_items` (y catálogos) mediante sus propios repositorios/datasources.

## 2. Requerimientos funcionales → comportamiento

### RF1 — Productos frecuentes

El usuario lista, filtra, crea, edita y elimina (lógico) productos que suele comprar.

Al **crear**, la foto del producto es **obligatoria** (se toma con la cámara). Editar no exige cambiarla. Productos ya existentes pueden no tener foto.

- Filtro: nombre, coincidencia parcial, case-insensitive sobre `name_normalized`.
- Listado operativo: solo `is_active = true`, orden alfabético por nombre.
- Eliminar no borra filas de historial.

### RF2 — Mercados

Igual que productos sobre el agregado `Market`.

- Filtro por nombre (y opcionalmente ubicación).
- Listado operativo: solo activos, orden alfabético.

### RF3 — Registrar una compra

Flujo de negocio (no de UI):

1. Configurar el mercado de la sesión (**obligatorio** antes de agregar ítems).
2. Seleccionar productos del catálogo activo e indicar **precio unitario**, **cantidad** (por defecto `1`) y **UoM** de la escalera del producto (por defecto la unidad mínima).
3. El total de la sesión es la sumatoria de `quantity * unitPrice` de todos los ítems. Ese total es un valor de dominio expuesto al presentation (p. ej. badge superior derecho): **no se calcula en el widget**.

Reglas:

- Solo una sesión `inProgress` a la vez.
- Mismo producto en la misma sesión: se actualiza (upsert), no se duplica.
- Completar persiste total, `completed_at` y pasa la sesión a historial.
- Cancelar descarta la sesión en curso y sus ítems. No genera historial.

### RF4 — Histórico

Lista sesiones `completed`, más recientes primero.

Filtros: mercado, rango de fechas (`completed_at`). Detalle: mercado (snapshot), fecha, ítems (nombre snapshot, cantidad, UoM, precio, subtotal) y total.

En esta versión el historial **no se edita ni se elimina**.

### RF5 — Última compra en el listado de productos

Al listar productos, cada uno puede exponer datos de última compra como etiquetas de dominio:

- mercado donde se compró la última vez (`market_name_snapshot`)
- precio unitario pagado en esa compra (`unit_price`)
- unidad de medida de esa compra (`uom` + `uomFactor` del tamaño de empaque)

Definición de “última vez”: el `shopping_item` cuya sesión está `completed` y tiene el `completed_at` máximo para ese `product_id`. Si no hay compras completadas, no hay etiquetas de última compra.

Estos datos son de **consulta**, no campos editables del producto.

El detalle de un producto también consulta su **historial de compras** (feature `products`, no `history`): cada ítem de sesiones `completed` de ese `product_id`, del más reciente al más antiguo. Cada fila usa snapshots (`market_name_snapshot`, `unit_price`) y la fecha `completed_at`. Editar el producto no reescribe filas pasadas. Las sesiones `inProgress` no aparecen.

### RF6 — Dashboard estadístico

Home de indicadores para que cualquier persona entienda si está mercando bien. Solo lectura. Período por defecto: **mes calendario actual**. Comparativo: **mes calendario anterior**.

No se diseñan pantallas aquí; solo el snapshot de negocio que la UI consumirá después.

### RF7 — Sugeridos para el próximo mercado

El usuario marca productos activos para el **próximo** mercado (`isSuggested`).

- Sugerir y quitar la sugerencia son acciones explícitas sobre el producto.
- Al listar el catálogo para una compra en curso, los sugeridos van **primero** (luego alfabético). El filtro por nombre conserva ese orden entre coincidencias.
- Completar una compra **quita** la sugerencia de cada producto que quedó en esa sesión. Cancelar no cambia sugerencias.
- Inactivos no se sugieren ni aparecen en el catálogo de compra.

### RF8 — Sugerencias de compra por mercado

Lista de lectura para decidir **dónde comprar más barato** cada producto, según el historial `completed` (cualquier fecha). No usa `isSuggested` ni sesiones `inProgress`/`cancelled`.

Definición: el precio de referencia de un producto es `MIN(unit_price)` histórico (igual que RF6). El mercado sugerido es aquel donde se observó ese mínimo. Si varios mercados empatan, gana la compra más reciente.

La UI agrupa por mercado, mercados alfabéticos, productos alfabéticos. Sin compras completadas: vacío.

## 3. Entidades y value objects

### Money

- Escala: 2 decimales.
- Siempre `>= 0`. Precios unitarios de ítem `> 0`.
- Operaciones de dominio (suma, producto cantidad × precio) viven aquí o en el agregado, nunca en UI.

### UnitOfMeasure

Catálogo **cerrado** en `core`. No hay tabla. Códigos persistidos:

| Código | Nombre | Dimensión | Base |
| --- | --- | --- | --- |
| `Und` | Unidad | conteo | 1 |
| `Lb` | Libra | masa | 453592 mg |
| `Lt` | Litro | volumen | 1_000_000 µL |
| `Ml` | Mililitro | volumen | 1000 µL |
| `Gr` | Gramo | masa | 1000 mg |
| `Kg` | Kilogramo | masa | 1_000_000 mg |
| `Pq` | Paquete | conteo | 1 |

Reglas:

- Obligatorio en cada ítem de compra. Default al agregar: `Und`.
- Parseo por código, case-insensitive. Código desconocido = `Failure.validation`.
- Conversión solo dentro de la misma dimensión. `Und` y `Pq` no se convierten entre sí.
- `unitPrice` es el precio **por esa UoM**. `lineTotal = quantity * unitPrice` no convierte unidades.
- Comparar precios entre UoM convertibles usa el precio por unidad base (mg o µL).
- Cada **producto** define una **escalera** de UoM seleccionables (ver `UomLadder`). El catálogo global no se elige libremente al comprar.

### UomLadder

Configuración por producto. Define qué unidades se pueden elegir al comprar y cómo se convierten a la unidad mínima.

| Campo | Regla |
| --- | --- |
| `base` | Unidad mínima. Del catálogo cerrado. Obligatoria. Default `Und` |
| `steps` | Empaques ordenados. Cada uno: UoM del catálogo (distinta de `base`) + `factor > 0` de **unidad mínima** |

El mismo código de catálogo puede repetirse si el factor es distinto: un producto puede venderse en `Pq → 3 Und` y también en `Pq → 4 Und`. No se duplica el mismo par (`uom`, `factor`). Un peldaño no puede usar la unidad mínima.

Ejemplos:

- Unidad mínima `Und`; peldaños `Pq → 3 Und` y `Pq → 4 Und`
- Unidad mínima `Lb`; peldaño `Pq → 3 Lb`

El factor de cada peldaño es la cantidad de unidad mínima que contiene **ese** empaque (no se encadena al peldaño anterior). `Und` y `Pq` sí se relacionan **en la escalera del producto**, aunque el catálogo global no los convierta.

Al comprar, la selección es un peldaño de `selectable` (`base` con factor 1 + cada empaque). Si hay varios tamaños del mismo código, hay que indicar el factor. Default: `base`. El ítem guarda `uom` y `uomFactor` (snapshot del tamaño).

### Product

| Campo | Regla |
| --- | --- |
| `id` | UUID |
| `name` | 1–80, trim, no vacío |
| `nameNormalized` | `name` en minúsculas, espacios colapsados; **único** entre activos y también como clave de unicidad global del catálogo |
| `notes` | opcional, máx. 280 |
| `isActive` | soft delete |
| `createdAt` / `updatedAt` | epoch ms |
| `uomLadder` | unidad mínima + peldaños; default `Und` sin peldaños |
| `photoPath` | ruta relativa de la foto en documentos de la app. **Obligatoria al crear**. Productos anteriores a esta regla pueden no tenerla |

Unicidad: no pueden existir dos productos con el mismo `nameNormalized`.

### Market

| Campo | Regla |
| --- | --- |
| `id` | UUID |
| `name` | 1–80, trim, no vacío, único por `nameNormalized` |
| `location` | opcional, máx. 120 |
| `notes` | opcional, máx. 280 |
| `isActive` | soft delete |
| `createdAt` / `updatedAt` | epoch ms |

### ProductLastPurchase (value object de lectura, RF5)

- `marketName`: snapshot del mercado
- `unitPrice`: `Money`
- `uom`: `UnitOfMeasure` de esa compra
- `purchasedAt`: `completed_at` de la sesión

### ShoppingSession

| Campo | Regla |
| --- | --- |
| `id` | UUID |
| `marketId` | mercado existente y **activo** al iniciar |
| `marketNameSnapshot` | copia del nombre al iniciar (y se mantiene al completar) |
| `status` | `inProgress` \| `completed` \| `cancelled` |
| `items` | 0..n; al completar debe haber **al menos 1** |
| `startedAt` | obligatorio |
| `completedAt` | solo si `completed` |
| `total` | suma de `lineTotal`; 0 si no hay ítems |

Transiciones:

```
(inicio) → inProgress → completed
                     → cancelled
```

No hay transición desde `completed` ni `cancelled`.

### ShoppingItem

| Campo | Regla |
| --- | --- |
| `id` | UUID |
| `sessionId` | sesión `inProgress` para mutar |
| `productId` | producto **activo** al agregar |
| `productNameSnapshot` | nombre al momento del upsert |
| `quantity` | `> 0`, máx. 9999, hasta 3 decimales |
| `uom` | código de catálogo del empaque elegido |
| `uomFactor` | cantidad de unidad mínima que contiene 1 de ese `uom` (1 si se compra en `base`) |
| `unitPrice` | `Money > 0` (precio por esa UoM) |
| `lineTotal` | `quantity * unitPrice` (2 decimales) |

Unicidad: (`sessionId`, `productId`).

### HistoryEntry (lectura)

Proyección de una sesión `completed`: id, mercado snapshot, fecha de cierre, total, cantidad de ítems.

### ProductPurchaseHistoryEntry (lectura, products)

Proyección de un ítem comprado en una sesión `completed`: id del ítem, mercado snapshot, precio unitario, cantidad, UoM, `completed_at`. Orden: más reciente primero. No pertenece al feature `history`.

### DashboardSnapshot (lectura, RF6)

Ver sección 5.

### MarketSuggestionGroup (lectura, RF8)

Por cada mercado, los productos cuyo **mejor precio conocido** se pagó ahí.

- `marketId`, `marketName` (snapshot del ítem que fijó el mínimo)
- `items`: producto (id + nombre snapshot), `unitPrice` mínimo, `uom` de esa compra

Un producto aparece en **un solo** mercado. Empate de precio: el `completed_at` más reciente.

## 4. Casos de uso

Cada uno es una clase. No fusionar. Fallos de negocio = `Failure` de dominio, no excepciones genéricas.

### products

| Use case | Regla de negocio |
| --- | --- |
| `ListProducts` | Activos; filtro opcional por nombre |
| `ListProductsWithLastPurchase` | Igual + `ProductLastPurchase?` por producto (RF5). Una consulta de listado, no N+1 en memoria |
| `ListProductPurchaseHistory` | Ítems de sesiones `completed` del producto; orden `completed_at DESC`. Snapshots inmutables |
| `GetProduct` | Por id; error si no existe |
| `CreateProduct` | Valida nombre, **foto** (archivo fuente no vacío) y escalera UoM; persiste la foto y guarda `photoPath`. Conflicto si `nameNormalized` existe (activo o inactivo: reactivar + actualizar + nueva foto, no duplicar) |
| `UpdateProduct` | Solo activos; unicidad de nombre excluyéndose a sí mismo; actualiza escalera UoM |
| `SoftDeleteProduct` | `isActive = false`. No afecta historial. No se puede elegir en nuevas compras |
| `SuggestProduct` | Solo activos. Marca `isSuggested = true` (idempotente si ya lo está) |
| `UnsuggestProduct` | Solo activos. Quita la marca (idempotente si no está sugerido) |

### markets

| Use case | Regla de negocio |
| --- | --- |
| `ListMarkets` | Activos; filtro opcional por nombre/ubicación |
| `GetMarket` | Por id |
| `CreateMarket` | Misma política de unicidad/reactivación que productos |
| `UpdateMarket` | Solo activos |
| `SoftDeleteMarket` | No se puede iniciar una compra en un mercado inactivo. Historial intacto |

### shopping

| Use case | Regla de negocio |
| --- | --- |
| `StartShopping` | Falla si ya hay `inProgress`. Falla si el mercado no existe o está inactivo. Crea sesión con snapshot de nombre y `total = 0` |
| `GetInProgressShopping` | Devuelve la sesión actual con ítems y total, o vacío |
| `UpsertShoppingItem` | Falla sin sesión `inProgress`. Falla si el producto no está activo. La UoM (y el factor, si hay varios tamaños del mismo código) debe coincidir con un empaque de la escalera (default: unidad mínima). Recalcula `lineTotal` y `total` |
| `RemoveShoppingItem` | Solo sesión `inProgress`. Recalcula `total` |
| `CompleteShopping` | Falla si no hay ítems. `status = completed`, `completedAt = now`, persiste `total`. En la misma transacción, `isSuggested = false` en los productos de los ítems |
| `CancelShopping` | `status = cancelled` (o borrado físico solo de la sesión inProgress y sus ítems; no toca `completed`) |

### history

| Use case | Regla de negocio |
| --- | --- |
| `ListCompletedShoppings` | `status = completed`; filtros mercado y rango de fechas; orden `completed_at DESC` |
| `GetShoppingDetail` | Sesión completada + ítems. Error si no existe o no está completada |

### dashboard

| Use case | Regla de negocio |
| --- | --- |
| `GetDashboardSnapshot` | Calcula el snapshot del período (default: mes actual) vs período anterior. Solo sesiones `completed` |
| `GetMarketPriceSuggestions` | Agrupa por mercado los productos cuyo mejor `unit_price` histórico se pagó ahí (RF8). Toda la historia `completed` |

## 5. Dashboard — indicadores (RF6)

Objetivo: que se entienda **si se está mercando bien**, no solo cuánto se gastó.

Período `P` = mes calendario actual (configurable después a rango). `P-1` = mes inmediatamente anterior.

Todas las métricas usan sesiones `completed` con `completedAt` en el rango.

### 5.1 Indicadores principales

1. **Gasto del período**  
   Suma de `total` en `P`.

2. **Variación vs período anterior**  
   `((gasto(P) - gasto(P-1)) / gasto(P-1)) * 100`  
   Si `gasto(P-1) = 0` y `gasto(P) = 0` → variación `0`.  
   Si `gasto(P-1) = 0` y `gasto(P) > 0` → variación no porcentual: marcar como “sin base de comparación”.

3. **Ticket promedio**  
   `gasto(P) / cantidad_de_compras(P)`.  
   Si no hay compras: no aplica.

4. **Número de compras**  
   Cantidad de sesiones completadas en `P`.

5. **Índice de eficiencia de mercadeo (0–100)** — indicador headline  
   Para cada ítem comprado en `P`, el **precio de referencia** es el mínimo `unit_price` histórico de ese producto en sesiones `completed` (cualquier mercado, cualquier fecha ≤ fin de `P`).  
   `exceso = Σ max(0, unitPrice_pagado − precio_referencia) * quantity`  
   `gastoÍtems = Σ unitPrice_pagado * quantity`  
   `eficiencia = 100 * (1 − exceso / gastoÍtems)`  
   Si no hay ítems: no aplica.  
   Interpretación de negocio:
   - **80–100:** se está comprando cerca del mejor precio conocido.
   - **50–79:** hay margen de mejora (conviene revisar mercados).
   - **0–49:** se está pagando sistemáticamente por encima del mejor precio histórico.

6. **Ahorro potencial del período**  
   Igual a `exceso` (dinero que se habría evitado pagando el mejor precio conocido). Debe ir junto al índice para que sea entendible.

### 5.2 Indicadores de apoyo

7. **Sobreprecios**  
   Lista de productos en `P` donde `unitPrice > precio_referencia`, con: nombre snapshot, mercado snapshot, precio pagado, mejor precio, diferencia. Orden: mayor diferencia primero. Tope de proyección: 10.

8. **Mercado más conveniente**  
   Entre mercados con al menos 1 compra en `P`, el de **mayor eficiencia** calculada igual que el índice pero restringida a ítems de ese mercado. Desempate: menor gasto. Si un mercado no tiene precios de referencia distintos (primera compra de esos productos), no se clasifica como “más conveniente”.

9. **Mercado con más gasto**  
   Informativo (no significa “mejor”). Suma de totales por `market_id` en `P`.

10. **Productos con más gasto**  
    Top 5 de `Σ lineTotal` en `P`.

11. **Tendencia de gasto**  
    Serie de los últimos 6 meses calendario: `{ monthStart, total }`. Lógica de datos, no gráfico.

### 5.3 Lo que el dashboard no es

- No es un editor de productos, mercados ni compras.
- No inventa presupuestos hasta que exista un RF de presupuesto.
- No usa sesiones `inProgress` ni `cancelled`.

## 6. Fallos de dominio (`Failure`)

Contratos estables. Presentation solo traduce a mensaje.

| Código | Cuándo |
| --- | --- |
| `validation` | Nombre vacío, precio ≤ 0, cantidad ≤ 0, longitud excedida |
| `notFound` | Entidad inexistente |
| `conflict` | Nombre duplicado; ya hay compra en curso |
| `precondition` | Completar sin ítems; mercado/producto inactivo; mutar sesión no `inProgress` |
| `inactive` | Operación sobre entidad soft-deleted no permitida |
| `storage` | Error de SQLite / disco (infraestructura) |

## 7. Persistencia (esquema canónico)

Una base SQLite. Migración inicial = versión 1.

### `products`

- `id TEXT PK`
- `name TEXT NOT NULL`
- `name_normalized TEXT NOT NULL UNIQUE`
- `notes TEXT`
- `is_active INTEGER NOT NULL DEFAULT 1`
- `created_at INTEGER NOT NULL`
- `updated_at INTEGER NOT NULL`
- `base_uom TEXT NOT NULL` (`Und` por defecto)
- `is_suggested INTEGER NOT NULL DEFAULT 0`
- `photo_path TEXT` (relativa; p. ej. `product_photos/{id}.jpg`). La foto vive en disco, no como BLOB

Índices: `is_active`, `is_suggested`.

### `product_uom_steps`

- `id TEXT PK`
- `product_id TEXT NOT NULL` → `products(id)`
- `uom TEXT NOT NULL`
- `factor REAL NOT NULL` (cantidad de `base_uom` que contiene 1 de ese `uom`)
- `sort_order INTEGER NOT NULL`
- `UNIQUE(product_id, uom, factor)`
- `UNIQUE(product_id, sort_order)`

Índice: `product_id`.

### `markets`

- `id TEXT PK`
- `name TEXT NOT NULL`
- `name_normalized TEXT NOT NULL UNIQUE`
- `location TEXT`
- `notes TEXT`
- `is_active INTEGER NOT NULL DEFAULT 1`
- `created_at INTEGER NOT NULL`
- `updated_at INTEGER NOT NULL`

Índice: `is_active`.

### `shopping_sessions`

- `id TEXT PK`
- `market_id TEXT NOT NULL` → `markets(id)`
- `market_name_snapshot TEXT NOT NULL`
- `status TEXT NOT NULL` (`inProgress` \| `completed` \| `cancelled`)
- `started_at INTEGER NOT NULL`
- `completed_at INTEGER`
- `total_amount REAL NOT NULL DEFAULT 0`

Índices: `status`, `completed_at`, `market_id`.  
Índice único parcial de negocio: como máximo una fila `status = inProgress` (hacer cumplir en use case y, si el motor lo permite, índice único filtrado o validación en transacción).

### `shopping_items`

- `id TEXT PK`
- `session_id TEXT NOT NULL` → `shopping_sessions(id)` ON DELETE CASCADE
- `product_id TEXT NOT NULL` → `products(id)`
- `product_name_snapshot TEXT NOT NULL`
- `quantity REAL NOT NULL`
- `uom TEXT NOT NULL` (`Und` \| `Lb` \| `Lt` \| `Ml` \| `Gr` \| `Kg` \| `Pq`)
- `uom_factor REAL NOT NULL` (default 1; snapshot del tamaño de empaque)
- `unit_price REAL NOT NULL`
- `line_total REAL NOT NULL`
- `UNIQUE(session_id, product_id)`

Índices: `product_id`, `session_id`.

### Consultas críticas (no N+1)

**RF5 — última compra por producto:** para el conjunto de productos listados, una consulta que obtenga el ítem cuya sesión `completed` tiene `MAX(completed_at)` por `product_id` (ventana o join con subconsulta agregada).

**Historial de compras de un producto:** `shopping_items` + `shopping_sessions` filtrado por `product_id` y `status = completed`, `ORDER BY completed_at DESC`.

**Dashboard — precio de referencia:** `MIN(unit_price)` por `product_id` en ítems de sesiones `completed` con `completed_at <= fin(P)`.

**RF8 — sugerencias por mercado:** una consulta de ítems `completed` cuyo `unit_price` es el `MIN` de ese `product_id`. Un producto → un mercado (desempate `completed_at` máximo). Agrupar en domain, no hidratar todo el historial.

**Completar compra:** transacción: validar ítems, actualizar `status`, `completed_at`, `total_amount`, y `is_suggested = 0` en los `product_id` de los ítems.

**Catálogo al mercar:** `is_active = 1`, filtro opcional por `name_normalized`, `ORDER BY is_suggested DESC, name`.

## 8. Límites de esta versión

- Un solo usuario local. Sin auth ni sync.
- Sin categorías de producto, sin presupuesto. La marca `isSuggested` es la única lista de “para el próximo mercado”.
- UoM: catálogo cerrado en core. Cada producto define su escalera (unidad mínima + peldaños). No se crean unidades ad hoc.
- Sin edición ni borrado de historial.
- Sin diseño de pantallas.
