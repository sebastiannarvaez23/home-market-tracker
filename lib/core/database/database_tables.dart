abstract final class DatabaseTables {
  static const products = 'products';
  static const productUomSteps = 'product_uom_steps';
  static const markets = 'markets';
  static const shoppingSessions = 'shopping_sessions';
  static const shoppingItems = 'shopping_items';
}

abstract final class ProductColumns {
  static const id = 'id';
  static const name = 'name';
  static const nameNormalized = 'name_normalized';
  static const notes = 'notes';
  static const isActive = 'is_active';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const baseUom = 'base_uom';
  static const isSuggested = 'is_suggested';
  static const photoPath = 'photo_path';
}

abstract final class ProductUomStepColumns {
  static const id = 'id';
  static const productId = 'product_id';
  static const uom = 'uom';
  static const factor = 'factor';
  static const sortOrder = 'sort_order';
}

abstract final class MarketColumns {
  static const id = 'id';
  static const name = 'name';
  static const nameNormalized = 'name_normalized';
  static const location = 'location';
  static const notes = 'notes';
  static const isActive = 'is_active';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

abstract final class ShoppingSessionColumns {
  static const id = 'id';
  static const marketId = 'market_id';
  static const marketNameSnapshot = 'market_name_snapshot';
  static const status = 'status';
  static const startedAt = 'started_at';
  static const completedAt = 'completed_at';
  static const totalAmount = 'total_amount';
}

abstract final class ShoppingItemColumns {
  static const id = 'id';
  static const sessionId = 'session_id';
  static const productId = 'product_id';
  static const productNameSnapshot = 'product_name_snapshot';
  static const quantity = 'quantity';
  static const uom = 'uom';
  static const uomFactor = 'uom_factor';
  static const unitPrice = 'unit_price';
  static const lineTotal = 'line_total';
}

abstract final class LastPurchaseColumns {
  static const marketNameSnapshot = 'lp_market_name_snapshot';
  static const unitPrice = 'lp_unit_price';
  static const uom = 'lp_uom';
  static const uomFactor = 'lp_uom_factor';
  static const purchasedAt = 'lp_completed_at';
}

abstract final class ShoppingSessionStatusValues {
  static const inProgress = 'inProgress';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}
