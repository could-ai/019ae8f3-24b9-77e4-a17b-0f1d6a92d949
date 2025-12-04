class ServiceItem {
  final String description;
  final double price;

  ServiceItem({required this.description, required this.price});
}

class WorkOrder {
  final String id;
  final String clientName;
  final String clientContact;
  final String licensePlate;
  final int mileage;
  final List<ServiceItem> services;
  final DateTime date;

  WorkOrder({
    required this.id,
    required this.clientName,
    required this.clientContact,
    required this.licensePlate,
    required this.mileage,
    required this.services,
    required this.date,
  });

  double get totalAmount {
    return services.fold(0, (sum, item) => sum + item.price);
  }
}
