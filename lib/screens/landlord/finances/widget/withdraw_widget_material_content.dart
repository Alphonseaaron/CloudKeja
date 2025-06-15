import 'package:flutter/material.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/helpers/my_loader.dart'; // Adaptive loader

class WithdrawWidgetMaterialContent extends StatefulWidget {
  const WithdrawWidgetMaterialContent({
    Key? key,
    this.balance,
  }) : super(key: key);

  final double? balance;

  @override
  State<WithdrawWidgetMaterialContent> createState() => _WithdrawWidgetMaterialContentState();
}

class _WithdrawWidgetMaterialContentState extends State<WithdrawWidgetMaterialContent> {
  String? amount;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // This content is designed to be shown in a ModalBottomSheet.
    // The DraggableScrollableSheet and outer GestureDetectors for dismissal
    // are typically part of how showModalBottomSheet is structured by the caller,
    // not part of the content widget itself.
    // For simplicity, this content widget will just return its core UI.

    return Container( // This container would be the direct child of DraggableScrollableSheet's builder
      decoration: BoxDecoration(
        color: colorScheme.surface, // Themed background
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20.0), // Padding for all content
      child: Form(
        key: _formKey,
        child: ListView( // Using ListView for scrollability if content grows
          // controller: controller, // controller would be passed from DraggableScrollableSheet
          shrinkWrap: true, // Take minimum space needed by children
          children: [
            Center( // Drag handle
              child: Container(
                width: 40, // Standard width for drag handle
                height: 4,
                decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.3), // Themed drag handle
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16), // Spacing after handle
            Text(
              'Withdraw Funds',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold), // Themed title
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Divider(color: colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 20),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  amount = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final double? enteredAmount = double.tryParse(value);
                if (enteredAmount == null) {
                  return 'Please enter a valid number';
                }
                if (widget.balance != null && enteredAmount > widget.balance!) {
                  return 'Amount exceeds available balance (KES ${widget.balance!.toStringAsFixed(2)})';
                }
                if (enteredAmount <= 0) {
                   return 'Amount must be greater than zero';
                }
                return null;
              },
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), // Inherit style, ensure contrast
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  hintText: 'Enter amount (KES)',
                  hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  // Using global InputDecorationTheme for border, filled, etc.
                  // Explicitly set fillColor if theme doesn't provide a suitable one.
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3), // Themed fill
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none, // Remove border if filled provides enough distinction
                  ),
                   prefixIcon: Icon(Icons.money, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox( // Ensure button takes full width or desired width
              width: double.infinity,
              height: 48, // Standard button height
              child: ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    // TODO: Implement actual withdrawal logic
                    await Future.delayed(const Duration(seconds: 2)); // Simulate network call
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Withdrawal of KES $amount initiated (mock).', style: TextStyle(color: colorScheme.onPrimary)), backgroundColor: colorScheme.primary)
                      );
                      Navigator.of(context).pop(true); // Indicate success
                    }
                    // setState(() => isLoading = false); // Handled by pop or error
                  }
                },
                // Style from ElevatedButtonThemeData or explicitly:
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: isLoading
                    ? MyLoader() // Already adaptive, will show CircularProgressIndicator
                    : const Text('Withdraw'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The amount withdrawn will be credited to the phone number registered with your account. Contact admin for any queries.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), // Themed informational text
            ),
            const SizedBox(height: 10), // Ensure some padding at the bottom
          ],
        ),
      ),
    );
  }
}
