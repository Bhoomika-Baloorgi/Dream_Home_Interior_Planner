class FurnitureItem {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final double defaultWidth;
  final double defaultHeight;

  const FurnitureItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    this.defaultWidth = 110,
    this.defaultHeight = 110,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'category': category,
    'defaultWidth': defaultWidth,
    'defaultHeight': defaultHeight,
  };

  factory FurnitureItem.fromJson(Map<String, dynamic> json) => FurnitureItem(
    id: json['id'],
    name: json['name'],
    imagePath: json['imagePath'],
    category: json['category'],
    defaultWidth: (json['defaultWidth'] as num?)?.toDouble() ?? 110,
    defaultHeight: (json['defaultHeight'] as num?)?.toDouble() ?? 110,
  );
}

class PlacedFurniture {
  final String furnitureId;
  final String imagePath;
  double x;
  double y;
  double scale;
  double rotation;   // NEW: rotation angle
  int zIndex;        // NEW: layering order

  PlacedFurniture({
    required this.furnitureId,
    required this.imagePath,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'furnitureId': furnitureId,
    'imagePath': imagePath,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
    'zIndex': zIndex,
  };

  factory PlacedFurniture.fromJson(Map<String, dynamic> json) => PlacedFurniture(
    furnitureId: json['furnitureId'],
    imagePath: json['imagePath'],
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    zIndex: (json['zIndex'] as int?) ?? 0,
  );
}

const List<FurnitureItem> furnitureData = [
  FurnitureItem(id: 'sofa', name: 'Sofa', imagePath: 'assets/furniture/sofa.png', category: 'Seating'),
  FurnitureItem(id: 'sofa_2', name: 'Sofa 2', imagePath: 'assets/furniture/sofa_2.png', category: 'Seating'),
  FurnitureItem(id: 'bed', name: 'Bed', imagePath: 'assets/furniture/bed.png', category: 'Bedroom'),
  FurnitureItem(id: 'bed_2', name: 'Bed 2', imagePath: 'assets/furniture/bed_2.png', category: 'Bedroom'),
  FurnitureItem(id: 'chair', name: 'Chair', imagePath: 'assets/furniture/chair.png', category: 'Seating'),
  FurnitureItem(id: 'chair_2', name: 'Chair 2', imagePath: 'assets/furniture/chair_2.png', category: 'Seating'),
  FurnitureItem(id: 'dining_chair', name: 'Dining Chair', imagePath: 'assets/furniture/dining_chair.png', category: 'Dining'),
  FurnitureItem(id: 'dining_chair_2', name: 'Dining Chair 2', imagePath: 'assets/furniture/dining_chair_2.png', category: 'Dining'),
  FurnitureItem(id: 'table', name: 'Table', imagePath: 'assets/furniture/table.png', category: 'Tables'),
  FurnitureItem(id: 'table_2', name: 'Table 2', imagePath: 'assets/furniture/table_2.png', category: 'Tables'),
  FurnitureItem(id: 'coffee_table', name: 'Coffee Table', imagePath: 'assets/furniture/coffee_table.png', category: 'Tables'),
  FurnitureItem(id: 'coffee_table_2', name: 'Coffee Table 2', imagePath: 'assets/furniture/coffee_table_2.png', category: 'Tables'),
  FurnitureItem(id: 'lamp', name: 'Lamp', imagePath: 'assets/furniture/lamp.png', category: 'Lighting'),
  FurnitureItem(id: 'lamp_2', name: 'Lamp 2', imagePath: 'assets/furniture/lamp_2.png', category: 'Lighting'),
  FurnitureItem(id: 'ceiling_light', name: 'Ceiling Light', imagePath: 'assets/furniture/ceiling_light.png', category: 'Lighting'),
  FurnitureItem(id: 'ceiling_light_2', name: 'Ceiling Light 2', imagePath: 'assets/furniture/ceiling_light_2.png', category: 'Lighting'),
  FurnitureItem(id: 'wardrobe', name: 'Wardrobe', imagePath: 'assets/furniture/wardrobe.png', category: 'Storage'),
  FurnitureItem(id: 'wardrobe_2', name: 'Wardrobe 2', imagePath: 'assets/furniture/wardrobe_2.png', category: 'Storage'),
  FurnitureItem(id: 'bookshelf', name: 'Bookshelf', imagePath: 'assets/furniture/bookshelf.png', category: 'Storage'),
  FurnitureItem(id: 'bookshelf_2', name: 'Bookshelf 2', imagePath: 'assets/furniture/bookshelf_2.png', category: 'Storage'),
  FurnitureItem(id: 'tv_unit', name: 'TV Unit', imagePath: 'assets/furniture/tv_unit.png', category: 'Entertainment'),
  FurnitureItem(id: 'tv_unit_2', name: 'TV Unit 2', imagePath: 'assets/furniture/tv_unit_2.png', category: 'Entertainment'),
  FurnitureItem(id: 'plant', name: 'Plant', imagePath: 'assets/furniture/plant.png', category: 'Decor'),
  FurnitureItem(id: 'plant_2', name: 'Plant 2', imagePath: 'assets/furniture/plant_2.png', category: 'Decor'),
  FurnitureItem(id: 'desk', name: 'Desk', imagePath: 'assets/furniture/desk.png', category: 'Office'),
  FurnitureItem(id: 'desk_2', name: 'Desk 2', imagePath: 'assets/furniture/desk_2.png', category: 'Office'),
  FurnitureItem(id: 'nightstand', name: 'Nightstand', imagePath: 'assets/furniture/nightstand.png', category: 'Bedroom'),
  FurnitureItem(id: 'nightstand_2', name: 'Nightstand 2', imagePath: 'assets/furniture/nightstand_2.png', category: 'Bedroom'),
  FurnitureItem(id: 'bean_bag', name: 'Bean Bag', imagePath: 'assets/furniture/bean_bag.png', category: 'Seating'),
  FurnitureItem(id: 'bean_bag_2', name: 'Bean Bag 2', imagePath: 'assets/furniture/bean_bag_2.png', category: 'Seating'),
  FurnitureItem(id: 'dining_table', name: 'Dining Table', imagePath: 'assets/furniture/dining_table.png', category: 'Dining'),
  FurnitureItem(id: 'dining_table_2', name: 'Dining Table 2', imagePath: 'assets/furniture/dining_table_2.png', category: 'Dining'),
  FurnitureItem(id: 'ottoman', name: 'Ottoman', imagePath: 'assets/furniture/ottoman.png', category: 'Seating'),
  FurnitureItem(id: 'ottoman_2', name: 'Ottoman 2', imagePath: 'assets/furniture/ottoman_2.png', category: 'Seating'),
];
