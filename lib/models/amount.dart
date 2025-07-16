class Amount {
  String? amountId;
  String? optionId;
  String amountValue;

  Amount({
    this.amountId,
    required this.optionId,
    required this.amountValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount_id': amountId,
      'option_id': optionId,
      'amount_value': amountValue,
    };
  }

  factory Amount.fromMap(Map<String, dynamic> map) {
    return Amount(
      amountId: map['amount_id'] as String?,
      optionId: map['option_id'] as String?,
      amountValue: map['amount_value'],
    );
  }
}
