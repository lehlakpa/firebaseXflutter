class BannerModel {
  final String id;
  final String image;

  BannerModel({required this.id, required this.image});

  factory BannerModel.fromFirestore(Map<String, dynamic>? data, String id) {
    return BannerModel(
      id: id,
      image: data?['image'] ?? '',
    );
  }
}
