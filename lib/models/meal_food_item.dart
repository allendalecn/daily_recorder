class MealFoodItem {
  final String name;
  final double amount;
  final String unit;
  final int calories;

  MealFoodItem({
    required this.name,
    required this.amount,
    this.unit = '克',
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'unit': unit,
    'calories': calories,
  };

  factory MealFoodItem.fromJson(Map<String, dynamic> json) => MealFoodItem(
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    unit: json['unit'] as String? ?? '克',
    calories: (json['calories'] as num).toInt(),
  );
}
