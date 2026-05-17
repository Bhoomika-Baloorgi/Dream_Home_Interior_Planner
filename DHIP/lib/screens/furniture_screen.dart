import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture_model.dart';
import '../models/design_model.dart';
import '../providers/app_provider.dart';
import '../widgets/furniture_card.dart';

class FurnitureScreen extends StatefulWidget {
  const FurnitureScreen({super.key});

  @override
  State<FurnitureScreen> createState() => _FurnitureScreenState();
}

class _FurnitureScreenState extends State<FurnitureScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final cats = furnitureData.map((f) => f.category).toSet().toList();
    return ['All', ...cats];
  }

  List<FurnitureItem> get _filteredFurniture {
    if (_selectedCategory == 'All') return furnitureData;
    return furnitureData
        .where((f) => f.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final currentCategory = roomCategories.firstWhere(
      (c) => c.id == provider.selectedRoomCategory,
      orElse: () => roomCategories.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentCategory.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/room-builder');
            },
            icon: const Icon(Icons.design_services, color: Colors.white),
            label: Text(
              'Open Builder',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: colorScheme.primary.withOpacity(0.08),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Furniture',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.3),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _filteredFurniture.length,
              itemBuilder: (context, index) {
                final item = _filteredFurniture[index];
                return Hero(
                  tag: 'furniture_${item.id}',
                  child: FurnitureCard(
                    item: item,
                    onTap: () {
                      provider.selectFurniture(item);
                      Navigator.pushNamed(context, '/room-builder');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
