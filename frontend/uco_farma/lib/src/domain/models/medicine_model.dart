
class Medicine {
  final String cn;
  final String name;
  final int quantity;
  final String type;
  final List<Dose>? doses;
  final bool wished;

  Medicine({
    required this.cn,
    required this.name,
    required this.quantity,
    required this.type,
    this.doses,
    required this.wished,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    print('Parsing medicine doses: ${json['doses']}'); // Debug
    return Medicine(
      cn: json['cn'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type'] ?? '',
      doses: json['doses'] != null && json['doses'] is List
          ? List<Dose>.from(
              (json['doses'] as List).map((x) => Dose.fromJson(x)))
          : null,
      wished: json['wished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'cn': cn,
        'name': name,
        'quantity': quantity,
        'type': type,
        'doses': doses?.map((x) => x.toJson()).toList(),
        'wished': wished,
      };
}

class Dose {
  final int frequency;
  final double quantity;

  Dose({
    required this.frequency,
    required this.quantity,
  });

  factory Dose.fromJson(Map<String, dynamic> json) {
    print('Parsing dose: $json'); // Debug
    return Dose(
      frequency: json['frequency'] is int 
          ? json['frequency'] 
          : int.tryParse(json['frequency'].toString()) ?? 0,
      quantity: json['quantity'] is double 
          ? json['quantity'] 
          : int.tryParse(json['quantity'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'quantity': quantity,
      };

  @override
  String toString() => 'Dose(frequency: $frequency, quantity: $quantity)';
}