class Medicine {
  final String cn;
  final String name;
  final int quantity;
  final String type;
  final String frequency;
  final String dose;
  
  Medicine({
    required this.cn,
    required this.name,
    required this.quantity,
    required this.type,
    required this.frequency,
    required this.dose,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      cn: json['cn'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type'] ?? 'solid',
      frequency: json['frequency'] ?? '',
      dose: json['dose'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cn': cn,
      'name': name,
      'quantity': quantity,
      'type': type,
      'frequency': frequency,
      'dose': dose,
    };
  }
} 