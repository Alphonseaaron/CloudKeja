import 'package:flutter/material.dart';
import 'package:cloudkeja/models/property_filter_state_model.dart';
import 'package:cloudkeja/config/app_config.dart'; // For filter constants
import 'package:cloudkeja/widgets/forms/multi_select_chip_field.dart'; // For multi-select chips
import 'package:intl/intl.dart'; // For currency formatting
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

class PropertyFiltersModal extends StatefulWidget {
  final PropertyFilterStateModel initialFilters;

  const PropertyFiltersModal({
    Key? key,
    required this.initialFilters,
  }) : super(key: key);

  @override
  State<PropertyFiltersModal> createState() => _PropertyFiltersModalState();
}

class _PropertyFiltersModalState extends State<PropertyFiltersModal> {
  late PropertyFilterStateModel _currentFilters;

  // Define price range defaults
  static const double _minPrice = 0.0;
  static const double _maxPrice = 500000.0; // Example: KES 0 to 500,000
  static const int _priceDivisions = 100; // For smoother steps

  late RangeValues _currentPriceRangeValues;

  // GlobalKeys for ShowcaseView
  final _priceRangeKey = GlobalKey();
  final _propertyTypeKey = GlobalKey();
  final _bedsKey = GlobalKey();
  final _bathsKey = GlobalKey();
  final _amenitiesKey = GlobalKey();
  final _applyButtonKey = GlobalKey();

  List<GlobalKey> _showcaseKeys = [];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters.copyWith();
    _currentPriceRangeValues = _currentFilters.priceRange ?? const RangeValues(_minPrice, _maxPrice);

    _showcaseKeys = [
      _priceRangeKey,
      _propertyTypeKey,
      _bedsKey,
      _bathsKey,
      _amenitiesKey,
      _applyButtonKey,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalkthroughService.startShowcaseIfNeeded(
        context: context,
        walkthroughKey: 'tenantPropertySearchFilters_v1',
        showcaseGlobalKeys: _showcaseKeys,
      );
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= _maxPrice) return 'KES ${NumberFormat("#,##0", "en_US").format(_maxPrice)}+';
    return 'KES ${NumberFormat("#,##0", "en_US").format(value)}';
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Common showcase text style
    TextStyle? showcaseTitleStyle = textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary);
    TextStyle? showcaseDescStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9));

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('tenantPropertySearchFilters_v1');
        debugPrint('PropertyFiltersModal showcase finished and marked as seen.');
      },
      builder: Builder(builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentFilters = PropertyFilterStateModel.initial();
                        _currentPriceRangeValues = const RangeValues(_minPrice, _maxPrice); // Reset slider
                      });
                    },
                    child: Text('Reset', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary)),
                  ),
                  Text('Filter Properties', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Showcase(
                    key: _applyButtonKey,
                    title: 'See Results',
                    description: "Once you've set your preferences, tap here to apply them and see matching properties.",
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: colorScheme.primary,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPriceRangeValues.start == _minPrice && _currentPriceRangeValues.end == _maxPrice && widget.initialFilters.priceRange == null) {
                           _currentFilters = _currentFilters.copyWith(clearPriceRange: true);
                        } else {
                           _currentFilters = _currentFilters.copyWith(priceRange: _currentPriceRangeValues);
                        }
                        Navigator.of(context).pop(_currentFilters);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: theme.dividerColor),

              // Body (Scrollable content)
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionTitle(context, 'Price Range (KES)'),
                    Showcase(
                      key: _priceRangeKey,
                      title: 'Set Your Budget',
                      description: 'Adjust the slider to define the minimum and maximum price for your search.',
                      titleTextStyle: showcaseTitleStyle,
                      descTextStyle: showcaseDescStyle,
                      showcaseBackgroundColor: colorScheme.primary,
                      child: Column(
                        children: [
                          RangeSlider(
                            values: _currentPriceRangeValues,
                            min: _minPrice,
                            max: _maxPrice,
                            divisions: _priceDivisions,
                            labels: RangeLabels(
                              _currentPriceRangeValues.start.round().toString(),
                              _currentPriceRangeValues.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentPriceRangeValues = values;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatCurrency(_currentPriceRangeValues.start), style: textTheme.bodySmall),
                                Text(_formatCurrency(_currentPriceRangeValues.end), style: textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: theme.dividerColor.withOpacity(0.5)),

                    _buildSectionTitle(context, 'Property Type'),
                    Showcase(
                      key: _propertyTypeKey,
                      title: 'Choose Property Type',
                      description: 'Select the type of property you are looking for, like "Apartment", "House", etc.',
                      titleTextStyle: showcaseTitleStyle,
                      descTextStyle: showcaseDescStyle,
                      showcaseBackgroundColor: colorScheme.primary,
                      child: MultiSelectChipField(
                        allOptions: kPropertyTypes,
                        initialSelectedOptions: _currentFilters.selectedPropertyTypes,
                        onSelectionChanged: (List<String> selected) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(selectedPropertyTypes: selected);
                          });
                        },
                      ),
                    ),
                    Divider(color: theme.dividerColor.withOpacity(0.5)),

                    _buildSectionTitle(context, 'Bedrooms'),
                    Showcase(
                      key: _bedsKey,
                      title: 'Number of Bedrooms',
                      description: 'Specify how many bedrooms you need. Select "Any" if you have no preference.',
                      titleTextStyle: showcaseTitleStyle,
                      descTextStyle: showcaseDescStyle,
                      showcaseBackgroundColor: colorScheme.primary,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: kBedroomOptions.map((option) {
                          bool isSelected = _currentFilters.selectedBedrooms == option;
                          return ChoiceChip(
                            label: Text(option == 0 ? 'Any' : (option == 5 ? '5+' : option.toString())),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _currentFilters = _currentFilters.copyWith(selectedBedrooms: option);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Divider(color: theme.dividerColor.withOpacity(0.5)),

                    _buildSectionTitle(context, 'Bathrooms'),
                    Showcase(
                      key: _bathsKey,
                      title: 'Number of Bathrooms',
                      description: 'Specify how many bathrooms you need. Select "Any" if flexible.',
                      titleTextStyle: showcaseTitleStyle,
                      descTextStyle: showcaseDescStyle,
                      showcaseBackgroundColor: colorScheme.primary,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: kBathroomOptions.map((option) {
                          bool isSelected = _currentFilters.selectedBathrooms == option;
                          return ChoiceChip(
                            label: Text(option == 0 ? 'Any' : (option == 3 ? '3+' : option.toString())),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _currentFilters = _currentFilters.copyWith(selectedBathrooms: option);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Divider(color: theme.dividerColor.withOpacity(0.5)),

                    _buildSectionTitle(context, 'Amenities'),
                    Showcase(
                      key: _amenitiesKey,
                      title: 'Essential Amenities',
                      description: 'Pick any must-have amenities, such as "Parking", "Pool", or "Security".',
                      titleTextStyle: showcaseTitleStyle,
                      descTextStyle: showcaseDescStyle,
                      showcaseBackgroundColor: colorScheme.primary,
                      child: MultiSelectChipField(
                        allOptions: kPropertyAmenities,
                        initialSelectedOptions: _currentFilters.selectedAmenities,
                        onSelectionChanged: (List<String> selected) {
                          setState(() {
                            _currentFilters = _currentFilters.copyWith(selectedAmenities: selected);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
