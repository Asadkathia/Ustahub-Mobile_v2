class TimeSlotModel {
  final String? slot;
  final String? startTime;
  final String? endTime;
  final bool? isBooked;

  TimeSlotModel({
    this.slot,
    this.startTime,
    this.endTime,
    this.isBooked,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      slot: json['slot'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isBooked: json['is_booked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'slot': slot,
        'start_time': startTime,
        'end_time': endTime,
        'is_booked': isBooked,
      };
}
