// Defines application-wide constants and configurations.

// List of predefined service provider types.
// This list can be used for dropdowns, filtering, and categorizing service providers.
const List<String> kServiceProviderTypes = [
  'Plumber', 'Drain Specialist', 'Water Heater Technician',
  'Electrician', 'Appliance Repair Electrician',
  'HVAC Technician', 'Furnace Repair', 'AC Repair',
  'Residential Cleaner', 'Deep Cleaning Specialist', 'Window Cleaner', 'Carpet Cleaner',
  'General Handyman', 'Furniture Assembly', 'Minor Repairs',
  'Interior Painter', 'Exterior Painter', 'Wallpaper Specialist',
  'Gardener', 'Lawn Care Specialist', 'Tree Trimmer',
  'Pest Control Technician',
  'General Appliance Repair',
  'Locksmith Services',
  'Movers',
  'Roofer / Roofing Repairs',
  'Flooring Installer', 'Floor Repair',
  'Window Installation/Repair', 'Door Installation/Repair',
  'General Contractor', 'Carpenter', 'Tiling Specialist', 'Drywall Installer',
  'Other', // Added 'Other' for flexibility
];

// --- Property Filter Constants ---

// Common property types for filtering searches.
const List<String> kPropertyTypes = [
  'Apartment',
  'House',
  'Studio',
  'Bedsitter',
  'Townhouse',
  'Villa',
  'Commercial',
  'Land',
  'Condo',
  'Duplex',
  'Office Space',
  'Retail Space',
  'Warehouse',
  'Other Property', // For types not explicitly listed
];

// Common property amenities for filtering.
const List<String> kPropertyAmenities = [
  'Parking',
  'Pets Allowed',
  'Furnished',
  'Unfurnished',
  'Semi-Furnished',
  'Balcony/Patio',
  'Swimming Pool',
  'Gym',
  'Security Gated',
  'Air Conditioning',
  'Washing Machine',
  'Internet Included', // Clarified from "Internet"
  'Dishwasher',
  'Elevator',
  'Wheelchair Accessible',
  'Garden/Yard',
  'Security System',
  'Serviced', // e.g., cleaning included
  'Backup Generator',
  'Borehole/Water Backup',
];

// Options for number of bedrooms. 0 represents "Any" or "Studio+", 5 represents "5+".
const List<int> kBedroomOptions = [0, 1, 2, 3, 4, 5];

// Options for number of bathrooms. 0 represents "Any", 3 represents "3+".
const List<int> kBathroomOptions = [0, 1, 2, 3];


// Example of other app-wide configurations that might go here:
// const String kAppVersion = "1.0.0";
// const String kApiBaseUrl = "https://api.example.com";
// const bool kEnableFeatureX = true;
