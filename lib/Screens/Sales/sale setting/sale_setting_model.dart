class SaleSettingModel {
  late num vatPercent;

  SaleSettingModel(this.vatPercent);

  SaleSettingModel.fromJson(Map<String, dynamic> json) : vatPercent = json['vatPercentage'] ?? '0';

  Map<dynamic, dynamic> toJson() => <String, dynamic>{'vatPercentage': vatPercent};
}
