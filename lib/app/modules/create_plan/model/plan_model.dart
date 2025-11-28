class PlanModel {
  final String? id;
  final String? serviceId;
  final String? providerId;
  final String? planType;
  final String? planTitle;
  final String? planPrice;
  final List<String> includedService;

  PlanModel({
    this.id,
    this.serviceId,
    this.providerId,
    this.planType,
    this.planTitle,
    this.planPrice,
    required this.includedService,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id']?.toString(),
      serviceId: json['service_id']?.toString(),
      providerId: json['provider_id']?.toString(),
      planType: json['plan_type']?.toString(),
      planTitle: json['plan_title']?.toString(),
      planPrice: json['plan_price']?.toString(),
      includedService:
          (json['included_service'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
