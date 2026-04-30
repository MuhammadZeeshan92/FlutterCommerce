class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String? image;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      price: (json["price"] as num).toDouble(),
      stock: json["stock"],
      image: json["image"],
    );
  }
}