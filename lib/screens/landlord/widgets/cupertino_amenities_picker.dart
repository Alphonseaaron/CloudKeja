import 'package:flutter/cupertino.dart';

class CupertinoAmenitiesPickerScreen extends StatefulWidget {
  final List<String> allAmenities;
  final List<String> initialSelectedAmenities;

  const CupertinoAmenitiesPickerScreen({
    Key? key,
    required this.allAmenities,
    required this.initialSelectedAmenities,
  }) : super(key: key);

  @override
  State<CupertinoAmenitiesPickerScreen> createState() => _CupertinoAmenitiesPickerScreenState();
}

class _CupertinoAmenitiesPickerScreenState extends State<CupertinoAmenitiesPickerScreen> {
  late List<String> _selectedAmenities;

  @override
  void initState() {
    super.initState();
    _selectedAmenities = List<String>.from(widget.initialSelectedAmenities);
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Select Amenities'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop(_selectedAmenities);
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: widget.allAmenities.map((amenity) {
                final bool isSelected = _selectedAmenities.contains(amenity);
                return CupertinoListTile(
                  title: Text(amenity),
                  trailing: isSelected 
                      ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue) 
                      : null,
                  onTap: () {
                    _toggleAmenity(amenity);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
