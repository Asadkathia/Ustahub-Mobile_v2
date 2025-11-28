class SearchModel {
  final int? id;
  final String keyword;

  SearchModel({this.id, required this.keyword});

  Map<String, dynamic> toMap() => {
        'id': id,
        'keyword': keyword,
      };

  factory SearchModel.fromMap(Map<String, dynamic> map) {
    return SearchModel(
      id: map['id'],
      keyword: map['keyword'],
    );
  }
}
