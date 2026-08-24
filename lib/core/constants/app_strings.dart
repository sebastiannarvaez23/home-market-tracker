abstract final class AppStrings {
  static const productsTitle = 'Productos';
  static const searchProductsHint = 'Buscar producto';
  static const neverPurchased = 'Sin compras';
  static const emptyProducts = 'Aún no tienes productos frecuentes.';
  static const emptySearch = 'No hay productos para esa búsqueda.';
  static const errorLoadProducts = 'No se pudieron cargar los productos.';
  static const retry = 'Reintentar';
  static const createProductTitle = 'Nuevo producto';
  static const createProductHint = 'Nombre del producto';
  static const productPhotoRequired = 'Toma una foto del producto.';
  static const productPhotoHint = 'Toca para fotografiar';
  static const productPhotoRetake = 'Toca para repetir';
  static const cancel = 'Cancelar';
  static const create = 'Crear';
  static const save = 'Guardar';
  static const productDetailTitle = 'Detalle';
  static const purchaseHistoryTitle = 'Historial de compras';
  static const emptyPurchaseHistory = 'Aún no has comprado este producto.';
  static const editProductTitle = 'Editar producto';
  static const productNotesHint = 'Notas (opcional)';
  static const errorLoadProduct = 'No se pudo cargar el producto.';
  static const suggestForNextShopping = 'Sugerir para el próximo mercado';
  static const unsuggestForNextShopping = 'Quitar de sugeridos';
  static const minUomLabel = 'Unidad mínima';
  static const addUomStep = 'Agregar empaque';
  static const uomFactorHint = 'Ej. 3';
  static const uomLadderTitle = 'Unidades de compra';
  static const uomLadderHint =
      'Cada empaque indica cuántas unidades mínimas contiene.';
  static const uomContainsLabel = 'de';

  static const homeTitle = 'Inicio';
  static const navHome = 'Inicio';
  static const navProducts = 'Productos';
  static const navHistory = 'Historial';
  static const dashboardPeriodLabel = 'Este mes';
  static const dashboardSpendLabel = 'Gasto';
  static const dashboardVariationLabel = 'Vs. mes anterior';
  static const dashboardPurchasesLabel = 'Compras';
  static const dashboardTicketLabel = 'Ticket promedio';
  static const dashboardEfficiencyTitle = 'Índice de mercadeo';
  static const dashboardEfficiencyEmpty =
      'Completa compras para ver si estás mercando bien.';
  static const dashboardEfficiencyHigh =
      'Estás comprando cerca del mejor precio conocido.';
  static const dashboardEfficiencyMedium =
      'Hay margen de mejora; conviene revisar mercados.';
  static const dashboardEfficiencyLow =
      'Estás pagando por encima del mejor precio histórico.';
  static const dashboardSavingsLabel = 'Ahorro potencial';
  static const dashboardNoComparison = 'Sin base de comparación';
  static const dashboardNotAvailable = '—';
  static const dashboardShortcutsTitle = 'Ir a';
  static const dashboardProductsShortcut = 'Productos';
  static const dashboardProductsShortcutHint = 'Tu catálogo frecuente';
  static const dashboardHistoryShortcut = 'Historial';
  static const dashboardHistoryShortcutHint = 'Mercados realizados';
  static const dashboardSuggestionsShortcut = 'Sugerencias';
  static const dashboardSuggestionsShortcutHint =
      'Qué comprar más barato en cada mercado';
  static const marketSuggestionsTitle = 'Sugerencias por mercado';
  static const marketSuggestionsHint =
      'Productos con el mejor precio que has pagado, agrupados por mercado.';
  static const marketSuggestionsBestPriceHint = 'Mejor precio conocido';
  static const emptyMarketSuggestions =
      'Completa compras para ver dónde te sale más barato cada producto.';
  static const errorLoadMarketSuggestions =
      'No se pudieron cargar las sugerencias.';
  static const dashboardMarketsTitle = 'Mercados';
  static const dashboardConvenientMarket = 'Más conveniente';
  static const dashboardHighestSpendMarket = 'Con más gasto';
  static const dashboardNoMarketInsight = 'Aún no hay datos de mercados.';
  static const dashboardTopProductsTitle = 'Productos con más gasto';
  static const dashboardNoTopProducts = 'Aún no hay productos este mes.';
  static const dashboardOverpricesTitle = 'Sobreprecios';
  static const dashboardTrendTitle = 'Tendencia de gasto';
  static const errorLoadDashboard = 'No se pudo cargar el inicio.';
  static const historyTitle = 'Historial';
  static const emptyHistory = 'Aún no has completado compras de mercado.';
  static const errorLoadHistory = 'No se pudieron cargar las compras.';
  static const historyDetailTitle = 'Detalle de compra';
  static const errorLoadHistoryDetail = 'No se pudo cargar el detalle.';
  static const historyItemsTitle = 'Productos';

  static String itemCountLabel(int count) {
    if (count == 1) return '1 producto';
    return '$count productos';
  }

  static String quantityWithUom(String quantity, String uom) {
    return '$quantity $uom';
  }

  static String paidVsBest(String paid, String best) {
    return 'Pagaste $paid · mejor $best';
  }

  static const startShopping = 'Mercar';
  static const startShoppingHint = 'Elige el mercado y arma tu lista';
  static const pickMarketTitle = '¿Dónde vas a mercar?';
  static const pickMarketEmpty = 'Crea tu primer mercado para empezar.';
  static const createMarketHint = 'Nombre del mercado';
  static const createAndStart = 'Crear y empezar';
  static const newMarket = 'Nuevo mercado';
  static const errorLoadMarkets = 'No se pudieron cargar los mercados.';
  static const shoppingTitle = 'Mercando';
  static const addProductPriceHint = '¿Cuánto vale hoy?';
  static const addProductQuantityHint = 'Cantidad';
  static const addToShopping = 'Agregar';
  static const updateShoppingItem = 'Actualizar';
  static const completeShopping = 'Terminar mercado';
  static const discardShopping = 'Descartar';
  static const discardShoppingConfirm = '¿Descartar esta compra?';
  static const emptyShoppingCatalog =
      'Crea productos en tu catálogo para agregarlos.';
  static const errorLoadShopping = 'No se pudo abrir la compra.';
  static const shoppingPackagingLabel = 'Empaque';
  static const invalidPrice = 'Indica un precio mayor a 0.';
  static const suggestedProducts = 'Sugeridos';
}
