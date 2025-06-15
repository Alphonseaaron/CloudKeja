import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloudkeja/models/location_model.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/maps/cupertino_maps_screen.dart';
import 'package:cloudkeja/main.dart'; // For GetMaterialApp if Get.to is used.
import 'package:get/get.dart';


// Generate mocks by running `flutter pub run build_runner build`
// Or define them manually as done in the thought process.
// For this tool, manual mocks are assumed.

class MockLocationProvider extends Mock implements LocationProvider {
  @override
  LocationData? get locationData => super.noSuchMethod(
        Invocation.getter(#locationData),
        returnValue: LocationData(latitude: -1.286389, longitude: 36.817223, timestamp: DateTime.now()),
        returnValueForMissingStub: LocationData(latitude: -1.286389, longitude: 36.817223, timestamp: DateTime.now()),
      );

  @override
  Future<void> getCurrentLocation() => super.noSuchMethod(
        Invocation.method(#getCurrentLocation, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

class MockPostProvider extends Mock implements PostProvider {
  @override
  Future<List<SpaceModel>> getSpaces() => super.noSuchMethod(
        Invocation.method(#getSpaces, []),
        returnValue: Future.value(<SpaceModel>[]),
        returnValueForMissingStub: Future.value(<SpaceModel>[]),
      );

  @override
  Future<List<SpaceModel>> searchSpaces(String query) => super.noSuchMethod(
        Invocation.method(#searchSpaces, [query]),
        returnValue: Future.value(<SpaceModel>[]),
        returnValueForMissingStub: Future.value(<SpaceModel>[]),
      );
}

class MockPlatformService extends Mock implements PlatformService {
  @override
  bool get useCupertino => super.noSuchMethod(Invocation.getter(#useCupertino), returnValue: true);
}


Widget createTestableWidget({
  required Widget child,
  required MockLocationProvider mockLocationProvider,
  required MockPostProvider mockPostProvider,
  required MockPlatformService mockPlatformService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LocationProvider>.value(value: mockLocationProvider),
      ChangeNotifierProvider<PostProvider>.value(value: mockPostProvider),
      Provider<PlatformService>.value(value: mockPlatformService),
    ],
    // Using GetMaterialApp because CupertinoMapsScreen uses Get.to for navigation
    // Tests might fail on navigation if not wrapped in GetMaterialApp or similar
    child: GetMaterialApp(
      home: CupertinoApp( // Wrap with CupertinoApp for Cupertino theming and context
        home: child,
      ),
    ),
  );
}

void main() {
  late MockLocationProvider mockLocationProvider;
  late MockPostProvider mockPostProvider;
  late MockPlatformService mockPlatformService;

  setUp(() {
    mockLocationProvider = MockLocationProvider();
    mockPostProvider = MockPostProvider();
    mockPlatformService = MockPlatformService();

    // Default stub for PlatformService to ensure it always returns true for Cupertino
    when(mockPlatformService.useCupertino).thenReturn(true);
    // Default stub for LocationProvider
    when(mockLocationProvider.locationData).thenReturn(
        LocationData(latitude: -1.286389, longitude: 36.817223, timestamp: DateTime.now()));
    when(mockLocationProvider.getCurrentLocation()).thenAnswer((_) async {});
  });

  testWidgets('CupertinoMapsScreen initial UI elements are rendered', (WidgetTester tester) async {
    when(mockPostProvider.getSpaces()).thenAnswer((_) async => []); // Return empty list initially

    await tester.pumpWidget(createTestableWidget(
      child: const CupertinoMapsScreen(),
      mockLocationProvider: mockLocationProvider,
      mockPostProvider: mockPostProvider,
      mockPlatformService: mockPlatformService,
    ));
    await tester.pumpAndSettle(); // Allow futures to complete (map style, getSpaces)

    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.text('Explore Spaces'), findsOneWidget); // Title in Nav Bar
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  testWidgets('CupertinoMapsScreen shows loading indicator', (WidgetTester tester) async {
    when(mockPostProvider.getSpaces()).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
      return [];
    });

    await tester.pumpWidget(createTestableWidget(
      child: const CupertinoMapsScreen(),
      mockLocationProvider: mockLocationProvider,
      mockPostProvider: mockPostProvider,
      mockPlatformService: mockPlatformService,
    ));

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget); // Initial loading
    await tester.pumpAndSettle(); // Let loading complete
    expect(find.byType(CupertinoActivityIndicator), findsNothing); // Should disappear
  });

  testWidgets('CupertinoMapsScreen shows "No Results" dialog on empty search', (WidgetTester tester) async {
    when(mockPostProvider.getSpaces()).thenAnswer((_) async => []); // Initial load
    when(mockPostProvider.searchSpaces(any)).thenAnswer((_) async => []);

    await tester.pumpWidget(createTestableWidget(
      child: const CupertinoMapsScreen(),
      mockLocationProvider: mockLocationProvider,
      mockPostProvider: mockPostProvider,
      mockPlatformService: mockPlatformService,
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'nonexistent place');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle(); // Allow search and dialog to show

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('No Results'), findsOneWidget);
    expect(find.text("No spaces found for 'nonexistent place'."), findsOneWidget);
  });

  testWidgets('CupertinoMapsScreen shows error dialog on getSpaces failure', (WidgetTester tester) async {
    when(mockPostProvider.getSpaces()).thenThrow(Exception('Failed to fetch spaces'));

    await tester.pumpWidget(createTestableWidget(
      child: const CupertinoMapsScreen(),
      mockLocationProvider: mockLocationProvider,
      mockPostProvider: mockPostProvider,
      mockPlatformService: mockPlatformService,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Could not load spaces. Please try again.'), findsOneWidget);
  });

  testWidgets('CupertinoMapsScreen shows error dialog on searchSpaces failure', (WidgetTester tester) async {
    when(mockPostProvider.getSpaces()).thenAnswer((_) async => []); // Initial load fine
    when(mockPostProvider.searchSpaces(any)).thenThrow(Exception('Search failed'));

    await tester.pumpWidget(createTestableWidget(
      child: const CupertinoMapsScreen(),
      mockLocationProvider: mockLocationProvider,
      mockPostProvider: mockPostProvider,
      mockPlatformService: mockPlatformService,
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'search term');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
    // The actual message depends on the implementation, this is what was in _fetchSpacesAndSetMarkers
    expect(find.text('Could not load spaces. Please try again.'), findsOneWidget);
  });
}
