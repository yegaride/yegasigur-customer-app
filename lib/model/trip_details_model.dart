import 'dart:convert';

import 'package:flutter/foundation.dart';

class TripDetailsModel {
  TripDetailsModel({
    required this.destinationAddresses,
    required this.originAddresses,
    required this.rows,
    required this.status,
    required this.startLat,
    required this.startLng,
    required this.safeLocationLat,
    required this.safeLocationLng,
  });

  List<String> destinationAddresses;
  List<String> originAddresses;
  List<Row> rows;
  String status;
  String startLat;
  String startLng;
  String safeLocationLat;
  String safeLocationLng;

  TripDetailsModel copyWith({
    List<String>? destinationAddresses,
    List<String>? originAddresses,
    List<Row>? rows,
    String? status,
    String? startLat,
    String? startLng,
    String? safeLocationLat,
    String? safeLocationLng,
  }) {
    return TripDetailsModel(
      destinationAddresses: destinationAddresses ?? this.destinationAddresses,
      originAddresses: originAddresses ?? this.originAddresses,
      rows: rows ?? this.rows,
      status: status ?? this.status,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      safeLocationLat: safeLocationLat ?? this.safeLocationLat,
      safeLocationLng: safeLocationLng ?? this.safeLocationLng,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'destination_addresses': destinationAddresses,
      'origin_addresses': originAddresses,
      'rows': rows.map((x) => x.toMap()).toList(),
      'startLat': startLat,
      'startLng': startLng,
      'safeLocationLat': safeLocationLat,
      'safeLocationLng': safeLocationLng,
      'status': status,
    };
  }

  factory TripDetailsModel.fromMap(Map<String, dynamic> map) {
    return TripDetailsModel(
      startLat: map['startLat'] as String,
      startLng: map['startLng'] as String,
      safeLocationLat: map['safeLocationLat'] as String,
      safeLocationLng: map['safeLocationLng'] as String,
      status: map['status'] as String,
      destinationAddresses: List<String>.from((map['destination_addresses'])),
      originAddresses: List<String>.from((map['origin_addresses'])),
      rows: List<Row>.from((map['rows'] as List).map<Row>((x) => Row.fromMap(x as Map<String, dynamic>))),
    );
  }

  String toJson() => json.encode(toMap());

  factory TripDetailsModel.fromJson(String source) => TripDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TripDetailsModel(destinationAddresses: $destinationAddresses, originAddresses: $originAddresses, rows: $rows, status: $status, startLat: $startLat, startLng: $startLng, safeLocationLat: $safeLocationLat, safeLocationLng: $safeLocationLng)';
  }

  @override
  bool operator ==(covariant TripDetailsModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.destinationAddresses, destinationAddresses) &&
        listEquals(other.originAddresses, originAddresses) &&
        listEquals(other.rows, rows) &&
        other.status == status;
  }

  @override
  int get hashCode {
    return destinationAddresses.hashCode ^ originAddresses.hashCode ^ rows.hashCode ^ status.hashCode;
  }
}

class Row {
  List<Element> elements;
  Row({
    required this.elements,
  });

  Row copyWith({
    List<Element>? elements,
  }) {
    return Row(
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'elements': elements.map((x) => x.toMap()).toList(),
    };
  }

  factory Row.fromMap(Map<String, dynamic> map) {
    return Row(
      elements: List<Element>.from(
        (map['elements'] as List).map<Element>(
          (x) => Element.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Row.fromJson(String source) => Row.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Row(elements: $elements)';

  @override
  bool operator ==(covariant Row other) {
    if (identical(this, other)) return true;

    return listEquals(other.elements, elements);
  }

  @override
  int get hashCode => elements.hashCode;
}

class Element {
  Distance distance;
  Distance duration;
  String status;
  Element({
    required this.distance,
    required this.duration,
    required this.status,
  });

  Element copyWith({
    Distance? distance,
    Distance? duration,
    String? status,
  }) {
    return Element(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distance': distance.toMap(),
      'duration': duration.toMap(),
      'status': status,
    };
  }

  factory Element.fromMap(Map<String, dynamic> map) {
    return Element(
      distance: Distance.fromMap(map['distance'] as Map<String, dynamic>),
      duration: Distance.fromMap(map['duration'] as Map<String, dynamic>),
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Element.fromJson(String source) => Element.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Element(distance: $distance, duration: $duration, status: $status)';

  @override
  bool operator ==(covariant Element other) {
    if (identical(this, other)) return true;

    return other.distance == distance && other.duration == duration && other.status == status;
  }

  @override
  int get hashCode => distance.hashCode ^ duration.hashCode ^ status.hashCode;
}

class Distance {
  String text;
  int value;
  Distance({
    required this.text,
    required this.value,
  });

  Distance copyWith({
    String? text,
    int? value,
  }) {
    return Distance(
      text: text ?? this.text,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'value': value,
    };
  }

  factory Distance.fromMap(Map<String, dynamic> map) {
    return Distance(
      text: map['text'] as String,
      value: map['value'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Distance.fromJson(String source) => Distance.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Distance(text: $text, value: $value)';

  @override
  bool operator ==(covariant Distance other) {
    if (identical(this, other)) return true;

    return other.text == text && other.value == value;
  }

  @override
  int get hashCode => text.hashCode ^ value.hashCode;
}
