class Medicine {
  String name;
  String frequency;
  List<String> times;
  double doseAmount;
  String doseUnit;
  double totalQuantity;
  String alarmTone;

  Medicine({
    required this.name,
    required this.frequency,
    required this.times,
    required this.doseAmount,
    required this.doseUnit,
    required this.totalQuantity,
    required this.alarmTone,
  });
}
