class TermsAanPrivacyModel {
  late String title, description;
  late bool isActive;
  TermsAanPrivacyModel({
    required this.title,
    required this.description,
    required this.isActive,
  });
  TermsAanPrivacyModel.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'] ?? '',
        description = json['description'] ?? '',
        isActive = json['isActive'] ?? false;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'description': description,
        'isActive': isActive,
      };
}
