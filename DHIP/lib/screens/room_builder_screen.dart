import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/design_model.dart';
import '../models/furniture_model.dart';
import '../providers/app_provider.dart';

class RoomBuilderScreen extends StatefulWidget {
  const RoomBuilderScreen({super.key});

  @override
  State<RoomBuilderScreen> createState() => _RoomBuilderScreenState();
}

class _RoomBuilderScreenState extends State<RoomBuilderScreen> {
  String? _customRoomImagePath;
  String? _assetRoomImagePath;
  final List<PlacedFurniture> _placedItems = [];
  final _uuid = const Uuid();
  String? _selectedPlacedId;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      final catId = provider.selectedRoomCategory;
      if (catId != null) {
        final cat = roomCategories.firstWhere(
              (c) => c.id == catId,
          orElse: () => roomCategories.first,
        );
        setState(() => _assetRoomImagePath = cat.imagePath);
      }


      final editingDesign = provider.editingDesign;
      if (editingDesign != null) {
        setState(() {
          _assetRoomImagePath = editingDesign.roomImagePath;
          _placedItems.clear();
          _placedItems.addAll(editingDesign.placedFurniture);
        });
      }

      // Handle quick furniture add
      if (provider.selectedFurniture != null) {
        _addFurnitureCenter(provider.selectedFurniture!);
        provider.selectFurniture(null);
      }
    });
  }


  void _addFurnitureCenter(FurnitureItem item) {
    setState(() {
      _placedItems.add(PlacedFurniture(
        furnitureId: _uuid.v4(),
        imagePath: item.imagePath,
        x: 120,
        y: 120,
        scale: 1.0,
      ));
    });
  }

  Future<void> _pickRoomImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _customRoomImagePath = picked.path;
        _assetRoomImagePath = null;
      });
    }
  }

  Future<void> _saveDesign() async {
    final provider = context.read<AppProvider>();
    final nameController = TextEditingController(
      text: 'My Design ${provider.savedDesigns.length + 1}',
    );

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Save Design',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Design Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    final design = RoomDesign(
      id: _uuid.v4(),
      name: name,
      roomCategory: provider.selectedRoomCategory ?? 'bedroom',
      roomImagePath: _assetRoomImagePath,
      placedFurniture: List.from(_placedItems),
      createdAt: DateTime.now(),
    );

    await provider.saveDesign(design);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Design "$name" saved!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _removeSelected() {
    if (_selectedPlacedId == null) return;
    setState(() {
      _placedItems.removeWhere((p) => p.furnitureId == _selectedPlacedId);
      _selectedPlacedId = null;
    });
  }

  void _clearAll() {
    setState(() {
      _placedItems.clear();
      _selectedPlacedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Room Builder',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All',
            onPressed: _placedItems.isEmpty ? null : _clearAll,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Design',
            onPressed: _saveDesign,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(colorScheme),
          Expanded(
            child: _buildCanvas(colorScheme),
          ),
          _buildFurniturePicker(colorScheme),
        ],
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _ToolbarButton(
            icon: Icons.image_outlined,
            label: 'Background',
            onTap: _pickRoomImage,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          if (_selectedPlacedId != null) ...[
            _ToolbarButton(
              icon: Icons.delete_outline,
              label: 'Remove',
              onTap: _removeSelected,
              colorScheme: colorScheme,
              isDestructive: true,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.zoom_in,
              label: 'Scale +',
              onTap: () {
                setState(() {
                  final item = _placedItems.firstWhere(
                      (p) => p.furnitureId == _selectedPlacedId);
                  item.scale = (item.scale + 0.15).clamp(0.3, 3.0);
                });
              },
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.zoom_out,
              label: 'Scale -',
              onTap: () {
                setState(() {
                  final item = _placedItems.firstWhere(
                      (p) => p.furnitureId == _selectedPlacedId);
                  item.scale = (item.scale - 0.15).clamp(0.3, 3.0);
                });
              },
              colorScheme: colorScheme,
            ),
          ],
          const Spacer(),
          Text(
            '${_placedItems.length} item${_placedItems.length == 1 ? '' : 's'}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DragTarget<FurnitureItem>(
          onAcceptWithDetails: (details) {
            final canvasBox = _canvasKey.currentContext
                ?.findRenderObject() as RenderBox?;
            if (canvasBox == null) return;
            final localPos = canvasBox.globalToLocal(details.offset);
            final item = details.data;
            setState(() {
              _placedItems.add(PlacedFurniture(
                furnitureId: _uuid.v4(),
                imagePath: item.imagePath,
                x: localPos.dx - (item.defaultWidth / 2),
                y: localPos.dy - item.defaultHeight,
                scale: 1.0,
              ));
            });
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTap: () => setState(() => _selectedPlacedId = null),
              child: Stack(
                key: _canvasKey,
                fit: StackFit.expand,
                children: [
                  _buildRoomBackground(colorScheme),
                  if (candidateData.isNotEmpty)
                    Container(
                      color: colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          'Drop here',
                          style: GoogleFonts.poppins(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ..._placedItems.map((placed) =>
                      _buildPlacedItem(placed, colorScheme)),
                  if (_placedItems.isEmpty && candidateData.isEmpty)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 48,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Drag furniture here',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomBackground(ColorScheme colorScheme) {
    if (_customRoomImagePath != null) {
      return Image.network(
        _customRoomImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultBackground(colorScheme),
      );
    }
    if (_assetRoomImagePath != null) {
      return Image.asset(
        _assetRoomImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultBackground(colorScheme),
      );
    }
    return _defaultBackground(colorScheme);
  }

  Widget _defaultBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceVariant,
            colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildPlacedItem(PlacedFurniture placed, ColorScheme colorScheme) {
    final isSelected = placed.furnitureId == _selectedPlacedId;
    final item = furnitureData.firstWhere(
      (f) => f.imagePath == placed.imagePath,
      orElse: () => furnitureData.first,
    );
    final width = item.defaultWidth * placed.scale;
    final height = item.defaultHeight * placed.scale;

    return Positioned(
      left: placed.x,
      top: placed.y,
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlacedId = placed.furnitureId),
        onPanUpdate: (details) {
          setState(() {
            placed.x += details.delta.dx;
            placed.y += details.delta.dy;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateX(-0.08),
                child: Image.asset(
                  placed.imagePath,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chair_alt,
                      color: colorScheme.primary,
                      size: 40 * placed.scale,
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: _removeSelected,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFurniturePicker(ColorScheme colorScheme) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Furniture — drag to place',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.55),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: furnitureData.length,
              itemBuilder: (context, index) {
                final item = furnitureData[index];
                return Draggable<FurnitureItem>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()..rotateX(-0.08),
                      child: Image.asset(
                        item.imagePath,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _furnitureChip(item, colorScheme),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _placedItems.add(PlacedFurniture(
                          furnitureId: _uuid.v4(),
                          imagePath: item.imagePath,
                          x: 80,
                          y: 80,
                          scale: 1.0,
                        ));
                      });
                    },
                    child: _furnitureChip(item, colorScheme),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _furnitureChip(FurnitureItem item, ColorScheme colorScheme) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.chair_alt,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.name,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.75),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDestructive;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}