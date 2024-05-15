class FeedbackModel {
  FeedbackModel({
    this.feedbackTitle,
    this.feedbackDescription,
    this.pictureUrl,
  });

  FeedbackModel.fromJson(dynamic json) {
    feedbackTitle = json['feedbackTitle'];
    feedbackDescription = json['feedbackDescription'];
    pictureUrl = json['pictureUrl'];
  }
  String? feedbackTitle;
  String? feedbackDescription;
  String? pictureUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['feedbackTitle'] = feedbackTitle;
    map['feedbackDescription'] = feedbackDescription;
    map['pictureUrl'] = pictureUrl;
    return map;
  }
}
