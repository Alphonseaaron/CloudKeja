import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/helpers/my_dropdown_material.dart';
import 'package:cloudkeja/helpers/my_dropdown_cupertino.dart';

class MyDropDown extends StatelessWidget {
  final String? hintText;
  final List<String>? options;
  final Function(String option) selectedOption;
  final String? currentValue;

  const MyDropDown({
    Key? key,
    this.hintText,
    required this.options, // Made options required as dropdown is less useful without them
    required this.selectedOption,
    this.currentValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return MyDropDownCupertino(
        key: key,
        hintText: hintText,
        options: options,
        selectedOption: selectedOption,
        currentValue: currentValue,
      );
    } else {
      return MyDropDownMaterial(
        key: key,
        hintText: hintText,
        options: options,
        selectedOption: selectedOption,
        currentValue: currentValue,
      );
    }
  }
}
