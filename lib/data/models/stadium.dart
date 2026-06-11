import 'package:flutter/material.dart';

@immutable
class Stadium {
  const Stadium({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.capacity,
    this.yearBuilt,
    this.nickname,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final int capacity;
  final int? yearBuilt;
  final String? nickname;

  factory Stadium.fromJson(Map<String, dynamic> json) => Stadium(
        id: json['id'] as String,
        name: json['name'] as String,
        city: json['city'] as String,
        country: json['country'] as String,
        capacity: json['capacity'] as int,
        yearBuilt: json['yearBuilt'] as int?,
        nickname: json['nickname'] as String?,
      );
}
