import 'dart:convert';
import 'furniture_model.dart';

class RoomDesign {
  final String id;
  final String name;
  final String roomCategory;
  final String? roomImagePath;
  final List<PlacedFurniture> placedFurniture;
  final DateTime createdAt;

  RoomDesign({
    required this.id,
    required this.name,
    required this.roomCategory,
    this.roomImagePath,
    required this.placedFurniture,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'roomCategory': roomCategory,
        'roomImagePath': roomImagePath,
        'placedFurniture':
            placedFurniture.map((f) => f.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory RoomDesign.fromJson(Map<String, dynamic> json) => RoomDesign(
        id: json['id'],
        name: json['name'],
        roomCategory: json['roomCategory'],
        roomImagePath: json['roomImagePath'],
        placedFurniture: (json['placedFurniture'] as List)
            .map((f) => PlacedFurniture.fromJson(f as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );

  String toJsonString() => jsonEncode(toJson());

  factory RoomDesign.fromJsonString(String jsonString) =>
      RoomDesign.fromJson(jsonDecode(jsonString));
}

class RoomCategory {
  final String id;
  final String name;
  final String imagePath;
  final String description;

  const RoomCategory({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
  });
}

const List<RoomCategory> roomCategories = [
  RoomCategory(
    id: 'bedroom',
    name: 'Bedroom',
    imagePath: 'assets/rooms/bedroom.png',
    description: 'Design your perfect bedroom',
  ),
  RoomCategory(
    id: 'living_room',
    name: 'Living Room',
    imagePath: 'assets/rooms/living_room.png',
    description: 'Create a cozy living space',
  ),
  RoomCategory(
    id: 'kitchen',
    name: 'Kitchen',
    imagePath: 'assets/rooms/kitchen.png',
    description: 'Plan your dream kitchen',
  ),
  RoomCategory(
    id: 'office',
    name: 'Home Office',
    imagePath: 'assets/rooms/office.png',
    description: 'Build your ideal workspace',
  ),
];
