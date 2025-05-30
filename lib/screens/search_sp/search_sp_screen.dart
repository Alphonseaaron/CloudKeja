import 'package:flutter/material.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel
import 'package:cloudkeja/widgets/tiles/sp_list_tile.dart'; // For SPListTile and SPListTileSkeleton
import 'package:cloudkeja/config/app_config.dart'; // For kServiceProviderTypes
import 'package:skeletonizer/skeletonizer.dart';
// import 'package:provider/provider.dart'; // If using a provider for search results later
// import 'package:cloudkeja/providers/sp_search_provider.dart'; // Example

class SearchSPScreen extends StatefulWidget {
  const SearchSPScreen({Key? key}) : super(key: key);
  static const String routeName = '/search-sp';

  @override
  State<SearchSPScreen> createState() => _SearchSPScreenState();
}

class _SearchSPScreenState extends State<SearchSPScreen> {
  final TextEditingController _searchTextController = TextEditingController();
  final TextEditingController _locationTextController = TextEditingController();
  String? _selectedSPType; // Null means "Any Service Type"

  List<UserModel> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDummyResults(); // Load initial dummy results
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _locationTextController.dispose();
    super.dispose();
  }

  void _loadDummyResults({bool simulateDelay = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    }

    // Create varied dummy Service Provider UserModels
    _searchResults = [
      UserModel(
          userId: 'sp001', name: 'John Doe Plumbing', role: 'ServiceProvider',
          serviceProviderTypes: ['Plumber', 'Drain Specialist'],
          spCounty: 'Nairobi', spCountry: 'Kenya', isVerified: true,
          profile: 'https://via.placeholder.com/150/007AFF/FFFFFF?Text=JD',
          servicesOffered: ['Emergency plumbing, Drain unblocking, Faucet repair'], // Example detailed services
          serviceAreas: ['Westlands, Kilimani, CBD'], // Example detailed areas
      ),
      UserModel(
          userId: 'sp002', name: 'Electra Fix Services', role: 'ServiceProvider',
          serviceProviderTypes: ['Electrician'],
          spCounty: 'Mombasa', spCountry: 'Kenya', isVerified: false,
          profile: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=EF',
          servicesOffered: ['Wiring, Light fixture installation, Fuse box repair'],
          serviceAreas: ['Nyali, Bamburi'],
      ),
      UserModel(
          userId: 'sp003', name: 'Clean Sweep Pros', role: 'ServiceProvider',
          serviceProviderTypes: ['Residential Cleaner', 'Deep Cleaning Specialist'],
          spCounty: 'Kisumu', spCountry: 'Kenya', isVerified: true,
          profile: 'https://via.placeholder.com/150/00FF00/FFFFFF?Text=CS',
          servicesOffered: ['Regular house cleaning, End-of-lease deep clean'],
          serviceAreas: ['Milimani, CBD, Polyview'],
      ),
      UserModel(
          userId: 'sp004', name: 'Handy Andy Repairs', role: 'ServiceProvider',
          serviceProviderTypes: ['General Handyman', 'Furniture Assembly'],
          spCounty: 'Nairobi', spCountry: 'Kenya', isVerified: true,
          profile: 'https://via.placeholder.com/150/FFA500/FFFFFF?Text=HA',
          servicesOffered: ['Picture hanging, Shelf installation, Flat-pack assembly'],
          serviceAreas: ['Karen, Lavington'],
      ),
       UserModel(
          userId: 'sp005', name: 'GreenThumb Gardeners', role: 'ServiceProvider',
          serviceProviderTypes: ['Gardener', 'Lawn Care Specialist'],
          spCounty: 'Nakuru', spCountry: 'Kenya', isVerified: false,
          profile: 'https://via.placeholder.com/150/228B22/FFFFFF?Text=GT',
          servicesOffered: ['Lawn mowing, Hedge trimming, Garden design'],
          serviceAreas: ['Milimani, Section 58'],
      ),
    ];

    // Simulate filtering based on current inputs (client-side for dummy data)
    if (_searchTextController.text.isNotEmpty) {
      String query = _searchTextController.text.toLowerCase();
      _searchResults = _searchResults.where((sp) =>
        (sp.name?.toLowerCase().contains(query) ?? false) ||
        (sp.servicesOffered?.any((s) => s.toLowerCase().contains(query)) ?? false) || // Search in detailed services
        (sp.serviceProviderTypes?.any((type) => type.toLowerCase().contains(query)) ?? false) // Search in types
      ).toList();
    }
    if (_selectedSPType != null) {
      _searchResults = _searchResults.where((sp) =>
        sp.serviceProviderTypes?.contains(_selectedSPType!) ?? false
      ).toList();
    }
    if (_locationTextController.text.isNotEmpty) {
      String query = _locationTextController.text.toLowerCase();
      _searchResults = _searchResults.where((sp) =>
        (sp.spCounty?.toLowerCase().contains(query) ?? false) ||
        (sp.spSubCounty?.toLowerCase().contains(query) ?? false) ||
        (sp.spCountry?.toLowerCase().contains(query) ?? false) ||
        (sp.serviceAreas?.any((area) => area.toLowerCase().contains(query)) ?? false)
      ).toList();
    }


    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Find Service Providers'),
        // AppBar uses AppBarTheme
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 1.0, // Subtle elevation
              // Card uses CardTheme
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _searchTextController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, service type...',
                        prefixIcon: Icon(Icons.search_outlined),
                      ),
                      onChanged: (value) { // Trigger search on text change (debounced in real app)
                        // For dummy data, can filter immediately or on search button tap
                        // _loadDummyResults();
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSPType,
                      decoration: const InputDecoration(
                        hintText: 'Any Service Type',
                        prefixIcon: Icon(Icons.category_outlined),
                        // border: OutlineInputBorder(), // From theme
                      ),
                      items: ['Any Service Type', ...kServiceProviderTypes].map((type) {
                        return DropdownMenuItem(
                          value: type == 'Any Service Type' ? null : type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSPType = value);
                        // _loadDummyResults(); // Optionally trigger search on change
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationTextController,
                      decoration: const InputDecoration(
                        hintText: 'Location (e.g., city, county)',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                       onChanged: (value) {
                        // _loadDummyResults();
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Search Providers'),
                      onPressed: () => _loadDummyResults(simulateDelay: true), // Simulate search
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Results Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadDummyResults(simulateDelay: true),
              child: Skeletonizer(
                enabled: _isLoading,
                effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_searchResults.isEmpty && !_isLoading)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                              const SizedBox(height: 20),
                              Text('No Service Providers Found', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
                              const SizedBox(height: 8),
                              Text('Try adjusting your search criteria or filters.', textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _isLoading ? 5 : _searchResults.length,
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return const SPListTileSkeleton(); // Use the dedicated skeleton widget
                          }
                          return SPListTile(serviceProvider: _searchResults[index]);
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
