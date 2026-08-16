enum ShoppingSessionStatus {
  inProgress,
  completed,
  cancelled;

  String get storageValue => name;

  static ShoppingSessionStatus fromStorage(String value) {
    return ShoppingSessionStatus.values.firstWhere(
      (status) => status.storageValue == value,
    );
  }
}
