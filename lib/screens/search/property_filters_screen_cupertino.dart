import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For RangeValues, RangeLabels (consider replacing if pure Cupertino needed)
import 'package:cloudkeja/models/property_filter_state_model.dart';
import 'package:cloudkeja/config/app_config.dart'; // For kPropertyTypes, kBedroomOptions, etc.
import 'package:cloudkeja/screens/search/widgets/cupertino_single_picker_screen.dart';
import 'package:cloudkeja/screens/search/widgets/cupertino_multi_picker_screen.dart';
import 'package:intl/intl.dart'; // For currency formatting

class PropertyFiltersScreenCupertino extends StatefulWidget {
  final PropertyFilterStateModel initialFilters;

  const PropertyFiltersScreenCupertino({
    Key? key,
    required this.initialFilters,
  }) : super(key: key);

  @override
  State<PropertyFiltersScreenCupertino> createState() => _PropertyFiltersScreenCupertinoState();
}

class _PropertyFiltersScreenCupertinoState extends State<PropertyFiltersScreenCupertino> {
  late PropertyFilterStateModel _currentFilters;
  // Using Material's RangeValues for state; UI will be Cupertino-styled text fields or sliders
  late RangeValues _currentPriceRangeValues; 

  static const double _minPrice = 0.0;
  static const double _maxPrice = 500000.0; 
  // For text input, divisions aren't strictly needed but can inform validation or steps
  // static const int _priceDivisions = 100; 

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters.copyWith();
    _currentPriceRangeValues = _currentFilters.priceRange ?? const RangeValues(_minPrice, _maxPrice);
    _minPriceController.text = _currentPriceRangeValues.start.round().toString();
    _maxPriceController.text = _currentPriceRangeValues.end.round().toString();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
  
  String _formatCurrency(double value, {bool isMax = false}) {
    if (isMax && value >= _maxPrice) return 'KES ${NumberFormat("#,##0", "en_US").format(_maxPrice)}+';
    return 'KES ${NumberFormat("#,##0", "en_US").format(value)}';
  }

  void _applyFilters() {
    // Update price range from text controllers before applying
    final double minPrice = double.tryParse(_minPriceController.text) ?? _minPrice;
    final double maxPrice = double.tryParse(_maxPriceController.text) ?? _maxPrice;
    final RangeValues newPriceRange = RangeValues(minPrice, maxPrice > minPrice ? maxPrice : minPrice + 1);

    if (newPriceRange.start == _minPrice && newPriceRange.end == _maxPrice && widget.initialFilters.priceRange == null) {
        _currentFilters = _currentFilters.copyWith(priceRange: newPriceRange, clearPriceRange: true);
    } else {
        _currentFilters = _currentFilters.copyWith(priceRange: newPriceRange);
    }
    Navigator.of(context).pop(_currentFilters);
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = PropertyFilterStateModel.initial();
      _currentPriceRangeValues = const RangeValues(_minPrice, _maxPrice);
      _minPriceController.text = _currentPriceRangeValues.start.round().toString();
      _maxPriceController.text = _currentPriceRangeValues.end.round().toString();
    });
  }

  Widget _buildPickerTile({
    required String label, 
    required String valueText, 
    required VoidCallback onTap
  }) {
    return CupertinoListTile.notched(
      title: Text(label),
      additionalInfo: Text(valueText, style: const TextStyle(overflow: TextOverflow.ellipsis)),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Filter Properties'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(), // Return null (no changes)
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Apply', style: TextStyle(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold)),
          onPressed: _applyFilters,
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            CupertinoListSection.insetGrouped(
              header: const Text('PRICE RANGE (KES)'),
              children: <Widget>[
                CupertinoTextFormFieldRow(
                  prefix: const Text('Min Price'),
                  controller: _minPriceController,
                  placeholder: _formatCurrency(_minPrice),
                  keyboardType: TextInputType.number,
                  onChanged: (value) { // Update RangeValues for other filters if they depend on it
                    final min = double.tryParse(value) ?? _minPrice;
                    final max = double.tryParse(_maxPriceController.text) ?? _maxPrice;
                    setState(() => _currentPriceRangeValues = RangeValues(min, max > min ? max : min +1));
                  },
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text('Max Price'),
                  controller: _maxPriceController,
                  placeholder: _formatCurrency(_maxPrice, isMax:true),
                  keyboardType: TextInputType.number,
                   onChanged: (value) {
                    final max = double.tryParse(value) ?? _maxPrice;
                    final min = double.tryParse(_minPriceController.text) ?? _minPrice;
                    setState(() => _currentPriceRangeValues = RangeValues(min, max > min ? max : min+1));
                  },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('PROPERTY DETAILS'),
              children: <Widget>[
                _buildPickerTile(
                  label: 'Property Type',
                  valueText: _currentFilters.selectedPropertyTypes.isEmpty ? 'Any' : _currentFilters.selectedPropertyTypes.join(', '),
                  onTap: () async {
                    final List<String>? result = await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => CupertinoMultiPickerScreen( // Changed to MultiPicker for consistency with Material
                        title: 'Select Property Types',
                        allOptions: kPropertyTypes, // From app_config.dart
                        initialSelectedOptions: _currentFilters.selectedPropertyTypes,
                      )),
                    );
                    if (result != null) setState(() => _currentFilters = _currentFilters.copyWith(selectedPropertyTypes: result));
                  },
                ),
                _buildPickerTile(
                  label: 'Bedrooms',
                  valueText: _currentFilters.selectedBedrooms == null || _currentFilters.selectedBedrooms == 0 
                              ? 'Any' 
                              : (_currentFilters.selectedBedrooms == 5 ? '5+' : _currentFilters.selectedBedrooms.toString()),
                  onTap: () { // Using CupertinoPicker directly in a modal
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => SizedBox(
                        height: 250,
                        child: CupertinoPicker(
                          backgroundColor: cupertinoTheme.scaffoldBackgroundColor,
                          itemExtent: 32.0,
                          scrollController: FixedExtentScrollController(
                            initialItem: kBedroomOptions.indexOf(_currentFilters.selectedBedrooms ?? 0),
                          ),
                          onSelectedItemChanged: (int index) {
                            setState(() => _currentFilters = _currentFilters.copyWith(selectedBedrooms: kBedroomOptions[index]));
                          },
                          children: kBedroomOptions.map((beds) => Center(child: Text(beds == 0 ? 'Any' : (beds == 5 ? '5+' : beds.toString())))).toList(),
                        ),
                      ),
                    );
                  },
                ),
                _buildPickerTile(
                  label: 'Bathrooms',
                   valueText: _currentFilters.selectedBathrooms == null || _currentFilters.selectedBathrooms == 0 
                              ? 'Any' 
                              : (_currentFilters.selectedBathrooms == 3 ? '3+' : _currentFilters.selectedBathrooms.toString()),
                  onTap: () {
                     showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => SizedBox(
                        height: 250,
                        child: CupertinoPicker(
                          backgroundColor: cupertinoTheme.scaffoldBackgroundColor,
                          itemExtent: 32.0,
                           scrollController: FixedExtentScrollController(
                            initialItem: kBathroomOptions.indexOf(_currentFilters.selectedBathrooms ?? 0),
                          ),
                          onSelectedItemChanged: (int index) {
                             setState(() => _currentFilters = _currentFilters.copyWith(selectedBathrooms: kBathroomOptions[index]));
                          },
                          children: kBathroomOptions.map((baths) => Center(child: Text(baths == 0 ? 'Any' : (baths == 3 ? '3+' : baths.toString())))).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('AMENITIES'),
              children: <Widget>[
                _buildPickerTile(
                  label: 'Select Amenities',
                  valueText: _currentFilters.selectedAmenities.isEmpty ? 'Any' : _currentFilters.selectedAmenities.join(', '),
                  onTap: () async {
                    final List<String>? result = await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => CupertinoMultiPickerScreen(
                        title: 'Select Amenities',
                        allOptions: kPropertyAmenities, // From app_config.dart
                        initialSelectedOptions: _currentFilters.selectedAmenities,
                      )),
                    );
                    if (result != null) setState(() => _currentFilters = _currentFilters.copyWith(selectedAmenities: result));
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CupertinoButton(
                // color: CupertinoColors.destructiveRed.resolveFrom(context), // Alternative styling for reset
                child: const Text('Reset Filters'),
                onPressed: _resetFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
