class TarotCard {
  final int id;
  final String name;
  final String imagePath;
  final String description;

  TarotCard({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    // 1. id 파싱: int면 그대로, String이면 변환 시도, null이면 0
    int parsedId = 0;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'];
      } else if (json['id'] is String) {
        parsedId = int.tryParse(json['id']) ?? 0;
      }
    }

    return TarotCard(
      id: parsedId,
      // 2. String 필드들: null이면 빈 문자열로 대체 (toString()으로 안전하게)
      name: json['name']?.toString() ?? '이름 없음',
      imagePath: json['imagePath']?.toString() ?? '',
      description: json['description']?.toString() ?? '설명 없음',
    );
  }
}