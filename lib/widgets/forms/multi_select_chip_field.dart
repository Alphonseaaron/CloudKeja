import 'package:flutter/widgets.dart'; // Using WidgetsFlutterBinding
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/forms/multi_select_chip_field_material.dart';
import 'package:cloudkeja/widgets/forms/multi_select_chip_field_cupertino.dart';

class MultiSelectChipField extends StatelessWidget {
  final List<String> allOptions;
  final List<String> initialSelectedOptions;
  final Function(List<String> selectedOptions) onSelectionChanged;
  final String? title;

  const MultiSelectChipField({
    Key? key,
    required this.allOptions,
    required this.initialSelectedOptions,
    required this.onSelectionChanged,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return MultiSelectChipFieldCupertino(
        key: key,
        allOptions: allOptions,
        initialSelectedOptions: initialSelectedOptions,
        onSelectionChanged: onSelectionChanged,
        title: title,
      );
    } else {
      return MultiSelectChipFieldMaterial(
        key: key,
        allOptions: allOptions,
        initialSelectedOptions: initialSelectedOptions,
        onSelectionChanged: onSelectionChanged,
        title: title,
      );
    }
  }
}
