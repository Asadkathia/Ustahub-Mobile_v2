class ServicesModelClass {
  String? id;
  String? name;
  String? description;
  String? icon;
  String? image;

  ServicesModelClass({
    this.id,
    this.name,
    this.description,
    this.icon,
    this.image,
  });

  ServicesModelClass.fromJson(Map<String, dynamic> json) {
    // Some queries (provider_services) nest the actual service under `services`
    final Map<String, dynamic> source =
        (json['services'] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(json['services'])
            : json;

    id = source['id']?.toString();
    name = source['name'] as String?;
    description = source['description'] as String?;
    icon = source['icon'] as String?;
    image = source['image'] as String?;
  }
}
