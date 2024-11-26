class Product {
  final String image;
  final String name;
  final int price;
  int quantity;

  Product({
    required this.image,
    required this.name,
    required this.price,
    this.quantity = 0, // Default quantity = 0
  });
}
