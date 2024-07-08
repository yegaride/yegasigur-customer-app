// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserSafeLocationModel {
  UserSafeLocationModel({
    required this.safeLocationLat,
    required this.safeLocationLng,
  });

  String safeLocationLat;
  String safeLocationLng;

  UserSafeLocationModel copyWith({
    String? safeLocationLat,
    String? safeLocationLng,
  }) {
    return UserSafeLocationModel(
      safeLocationLat: safeLocationLat ?? this.safeLocationLat,
      safeLocationLng: safeLocationLng ?? this.safeLocationLng,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'safe_location_lat': safeLocationLat,
      'safe_location_lng': safeLocationLng,
    };
  }

  factory UserSafeLocationModel.fromMap(Map<String, dynamic> map) {
    return UserSafeLocationModel(
      safeLocationLat: map['safe_location_lat'] as String,
      safeLocationLng: map['safe_location_lng'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSafeLocationModel.fromJson(String source) =>
      UserSafeLocationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserSafeLocationModel(safeLocationLat: $safeLocationLat, safeLocationLng: $safeLocationLng)';

  @override
  bool operator ==(covariant UserSafeLocationModel other) {
    if (identical(this, other)) return true;

    return other.safeLocationLat == safeLocationLat && other.safeLocationLng == safeLocationLng;
  }

  @override
  int get hashCode => safeLocationLat.hashCode ^ safeLocationLng.hashCode;
}
