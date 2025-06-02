import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // To get user details
import 'package:cloudkeja/helpers/my_dropdown.dart'; // Adaptive dropdown
import 'package:cloudkeja/helpers/mpesa_helper.dart'; // For mpesaPayment

class UserPaymentDialogCupertinoContent extends StatefulWidget {
  final SpaceModel space;

  const UserPaymentDialogCupertinoContent({Key? key, required this.space}) : super(key: key);

  @override
  State<UserPaymentDialogCupertinoContent> createState() => _UserPaymentDialogCupertinoContentState();
}

class _UserPaymentDialogCupertinoContentState extends State<UserPaymentDialogCupertinoContent> {
  String? _selectedPaymentOption;
  String? _selectedPaymentMethod;
  bool _isProcessingPayment = false;
  String? _errorMessage; // For displaying errors within the dialog

  // Helper method to build styled rows for payment summary
  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final textStyle = cupertinoTheme.textTheme.textStyle;
    final boldTextStyle = cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.bold);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? boldTextStyle : textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
          ),
          Text(value, style: isTotal ? boldTextStyle : textStyle),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.phone == null) {
      setState(() {
        _errorMessage = 'User phone number not available.';
      });
      return;
    }
    if (_selectedPaymentMethod == null || _selectedPaymentOption == null) {
       setState(() {
        _errorMessage = 'Please select payment amount and method.';
      });
      return;
    }


    setState(() {
      _isProcessingPayment = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      await mpesaPayment(
        amount: widget.space.price!.toDouble(), // Assuming full amount for now
        phone: user!.phone!,
      );
      // If successful, pop the dialog (or the parent AlertDialog will be handled)
      // Indicate success to the parent if needed, e.g., Navigator.of(context).pop(true);
      // For now, parent dialog handles dismissal.
      // This widget itself doesn't pop the whole AlertDialog.
      // We might want to have a success callback or pop with a specific result.
      // For simplicity, if it reaches here without error, it's "successful" from this widget's POV.
      // The calling UserProfileScreenCupertino will then dismiss the alert dialog.
      // Let's assume for now the parent will dismiss, or we can pop this content:
      if(mounted) Navigator.of(context).pop(true); // Pop this content, indicating success to alert dialog

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Payment failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final titleStyle = cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    
    return SizedBox( // Constrain width for dialog content
      width: MediaQuery.of(context).size.width * 0.8, // Example width constraint
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title "Payment For" is usually part of the AlertDialog's title,
          // but here content provides its own structure.
          // We can omit a top-level title here if UserProfileScreenCupertino's AlertDialog provides it.
          // Or add one if this content is meant to be fully self-contained:
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Text('Make Payment', style: cupertinoTheme.textTheme.navTitleTextStyle),
          // ),

          Text('Payment For', style: titleStyle),
          const SizedBox(height: 8),
          MyDropDown( // This is already platform-adaptive
            selectedOption: (val) => setState(() => _selectedPaymentOption = val),
            options: const ['Total Due Amount', 'Custom Amount'], // Example options
            hintText: 'Amount to pay',
            currentValue: _selectedPaymentOption,
          ),
          const SizedBox(height: 16),

          Text('Payment Using', style: titleStyle),
          const SizedBox(height: 8),
          MyDropDown(
            selectedOption: (val) => setState(() => _selectedPaymentMethod = val),
            options: const ['Mpesa'], // Example options
            hintText: 'Select payment method',
            currentValue: _selectedPaymentMethod,
          ),
          const SizedBox(height: 20),

          _buildSummaryRow(context, 'Amount Due:', 'KES ${widget.space.price?.toStringAsFixed(0) ?? '0'}'),
          const SizedBox(height: 8),
          
          // Using a simple line for divider in Cupertino
          Container(height: 0.5, color: CupertinoColors.separator.resolveFrom(context), margin: const EdgeInsets.symmetric(vertical: 10)),
          _buildSummaryRow(context, 'Total to Pay:', 'KES ${widget.space.price?.toStringAsFixed(0) ?? '0'}', isTotal: true),
          const SizedBox(height: 24),

          if (_errorMessage != null) 
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                _errorMessage!,
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.systemRed.resolveFrom(context)),
                textAlign: TextAlign.center,
              ),
            ),

          SizedBox( // Ensure button takes full width of this content dialog
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: _isProcessingPayment ? null : _processPayment,
              child: _isProcessingPayment
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white) // White for filled button
                  : const Text('Confirm & Pay'),
            ),
          )
        ],
      ),
    );
  }
}
