class DailybookingslotModel {
  final String? timerId;
  final String? slotschedule;
  final String? startTime; // Change Timer? to String?
  final String? endTime;   // Change Timer? to String?

  DailybookingslotModel({
    this.timerId,
    this.slotschedule,
    this.startTime,
    this.endTime,
  });

  factory DailybookingslotModel.fromJson(Map<String, dynamic> json) {
    return DailybookingslotModel(
      timerId: json['timer_id'] as String?,
      slotschedule: json['slot_schedule'] as String?,
      startTime: json['start_time'] as String?, // API returns string
      endTime: json['end_time'] as String?,     // API returns string
    );
  }
}
