import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:flutter/cupertino.dart'; // For potential Cupertino dialog elements

// Define status constants (could be moved to a config file later)
const String kUnitStatusVacant = 'vacant';
const String kUnitStatusOccupied = 'occupied';
const String kUnitStatusPending = 'pending_move_out';

class UnitDisplayCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> units;
  final bool isOwner;
  final String spaceId;

  const UnitDisplayCarousel({
    Key? key,
    required this.units,
    required this.isOwner,
    required this.spaceId,
  }) : super(key: key);

  // Helper to get color based on status
  Color _getStatusColor(String? status, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case kUnitStatusOccupied:
        return colors.error; // Red
      case kUnitStatusVacant:
        return Colors.green.shade600; // Green
      case kUnitStatusPending:
        return Colors.amber.shade700; // Yellow
      default:
        return colors.onSurface.withOpacity(0.5); // Grey for unknown
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case kUnitStatusOccupied:
        return 'Occupied';
      case kUnitStatusVacant:
        return 'Vacant';
      case kUnitStatusPending:
        return 'Pending Move-out';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const SizedBox.shrink(); // Or a message like "No unit information available"
    }

    // Group units by floor
    Map<int, List<Map<String, dynamic>>> unitsByFloor = {};
    for (var unit in units) {
      // Assuming 'floor' is an int. Add error handling or type conversion if needed.
      // Default to floor 0 if not specified or invalid.
      int floor = (unit['floor'] is int ? unit['floor'] : 0) as int;
      if (!unitsByFloor.containsKey(floor)) {
        unitsByFloor[floor] = [];
      }
      unitsByFloor[floor]!.add(unit);
    }

    // Sort floors (optional, but good for display)
    var sortedFloors = unitsByFloor.keys.toList()..sort();

    if (sortedFloors.isEmpty) {
       return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("No unit information available for display.", style: TextStyle(fontStyle: FontStyle.italic))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // If embedded in another scroll view
      itemCount: sortedFloors.length,
      itemBuilder: (context, index) {
        int floor = sortedFloors[index];
        List<Map<String, dynamic>> floorUnits = unitsByFloor[floor]!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Floor ${floor == 0 ? "N/A" : floor}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (isOwner)
                          TextButton.icon(
                            icon: Icon(Icons.add_circle_outline, size: 20),
                            label: Text('Add Unit'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap
                            ),
                            onPressed: () {
                              _showAddEditUnitDialog(context, spaceId, floor: floor);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: floorUnits.map((unit) {
                        String unitNumber = unit['unitNumber']?.toString() ?? 'N/A';
                        String status = unit['status']?.toString() ?? 'unknown';

                        Widget unitWidget = Chip(
                          avatar: CircleAvatar(
                            backgroundColor: _getStatusColor(status, context),
                            radius: 8,
                          ),
                          label: Text('$unitNumber (${_getStatusText(status)})'),
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        );

                        // Always allow tap, but action depends on isOwner and unit status
                        return GestureDetector(
                          onTap: () {
                            if (isOwner) {
                              _showAddEditUnitDialog(context, spaceId, existingUnit: unit, floor: floor);
                            } else {
                              // Tenant interaction logic
                              String? unitStatus = unit['status']?.toString();
                              String unitNumberDisplay = unit['unitNumber']?.toString() ?? 'N/A'; // Renamed to avoid conflict

                              if (unitStatus == kUnitStatusVacant) {
                                // Placeholder for initiating booking for a vacant unit
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Initiating booking process for Unit $unitNumberDisplay... (Placeholder)'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // TODO: Implement actual navigation or dialog for booking process in a future step.
                              } else if (unitStatus == kUnitStatusPending) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Unit $unitNumberDisplay is pending move-out. Check back soon!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else if (unitStatus == kUnitStatusOccupied) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Unit $unitNumberDisplay is currently occupied.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Unit $unitNumberDisplay status: ${_getStatusText(unitStatus)}.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          child: unitWidget,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

  void _showAddEditUnitDialog(BuildContext context, String spaceId, {Map<String, dynamic>? existingUnit, required int floor}) {
    final _formKey = GlobalKey<FormState>();
    String? unitNumber = existingUnit?['unitNumber']?.toString();
    String? status = existingUnit?['status']?.toString() ?? kUnitStatusVacant; // Default to vacant for new
    final bool isEditing = existingUnit != null;
    final String dialogTitle = isEditing ? 'Edit Unit' : 'Add New Unit to Floor $floor';

    // Available statuses for dropdown
    final List<String> statuses = [kUnitStatusVacant, kUnitStatusOccupied, kUnitStatusPending];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // To handle dropdown state, we need a StatefulWidget here or use a state management solution for the dialog.
        // For simplicity, we'll use a StatefulBuilder to manage the dropdown's state locally.
        String? currentSelectedStatus = status;

        return AlertDialog(
          title: Text(dialogTitle),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: unitNumber,
                      decoration: InputDecoration(labelText: 'Unit Number/Name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Unit number cannot be empty';
                        }
                        return null;
                      },
                      onSaved: (value) => unitNumber = value!.trim(),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: currentSelectedStatus,
                      decoration: InputDecoration(labelText: 'Status'),
                      items: statuses.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(_getStatusText(value)), // Use helper to get display text
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() { // Use StatefulBuilder's setState
                            currentSelectedStatus = newValue;
                          });
                        }
                      },
                      onSaved: (value) => status = value, // Save final selected status
                    ),
                  ],
                ),
              );
            }
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(isEditing ? 'Save Changes' : 'Add Unit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Use currentSelectedStatus from StatefulBuilder for the most up-to-date value
                  status = currentSelectedStatus;

                  final postProvider = Provider.of<PostProvider>(context, listen: false);
                  String unitId = isEditing ? existingUnit!['unitId'] as String
                                            : '${DateTime.now().millisecondsSinceEpoch}-${unitNumber!.replaceAll(' ','_')}';

                  Map<String, dynamic> unitData = {
                    'unitId': unitId,
                    'unitNumber': unitNumber,
                    'status': status,
                    'floor': floor,
                    // Add other fields as necessary, e.g., tenantId: null
                  };

                  if (isEditing) {
                    postProvider.updateUnitInSpace(spaceId, unitId, unitData)
                      .then((_) => Navigator.of(dialogContext).pop())
                      .catchError((err) {
                        Navigator.of(dialogContext).pop(); // Pop the dialog
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating unit: $err'), backgroundColor: Colors.red));
                      });
                  } else {
                    postProvider.addUnitToSpace(spaceId, unitData)
                      .then((_) => Navigator.of(dialogContext).pop())
                      .catchError((err) {
                         Navigator.of(dialogContext).pop(); // Pop the dialog
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding unit: $err'), backgroundColor: Colors.red));
                      });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
