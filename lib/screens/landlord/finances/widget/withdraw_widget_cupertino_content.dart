import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/helpers/my_loader.dart'; // Adaptive loader

class WithdrawWidgetCupertinoContent extends StatefulWidget {
  final double? balance;

  const WithdrawWidgetCupertinoContent({Key? key, this.balance}) : super(key: key);

  @override
  State<WithdrawWidgetCupertinoContent> createState() => _WithdrawWidgetCupertinoContentState();
}

class _WithdrawWidgetCupertinoContentState extends State<WithdrawWidgetCupertinoContent> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage; // For displaying validation errors

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    final enteredAmountStr = _amountController.text;
    if (enteredAmountStr.isEmpty) {
      setState(() => _errorMessage = 'Please enter an amount.');
      return;
    }
    final enteredAmount = double.tryParse(enteredAmountStr);
    if (enteredAmount == null) {
      setState(() => _errorMessage = 'Please enter a valid number.');
      return;
    }
    if (widget.balance != null && enteredAmount > widget.balance!) {
      setState(() => _errorMessage = 'Amount exceeds available balance (KES ${widget.balance!.toStringAsFixed(2)}).');
      return;
    }
    if (enteredAmount <= 0) {
      setState(() => _errorMessage = 'Amount must be greater than zero.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    // TODO: Implement actual withdrawal logic (e.g., call a provider method)
    await Future.delayed(const Duration(seconds: 2)); // Simulate network call

    if (mounted) {
      // Assuming success for this example, pop with true
      Navigator.of(context).pop(true);
      // In a real app, you might pop with false if the backend call fails,
      // and the caller would show an error dialog.
      // Or, handle error from backend here and update _errorMessage.
    }
    // No need to set isLoading = false if we are popping.
    // If we were to stay on this screen on error, then set it.
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    // This content is typically shown via showCupertinoModalPopup,
    // wrapped in a Container with specific height and background.
    // This widget provides the inner content.
    return Material( // Use Material for MediaQuery and Directionality if not already in tree
      type: MaterialType.transparency, // Avoid Material background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fit content
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Optional: Drag handle if presented in a draggable sheet manner
            // Center(
            //   child: Container(
            //     width: 40, height: 4,
            //     decoration: BoxDecoration(
            //       color: CupertinoColors.systemGrey4.resolveFrom(context),
            //       borderRadius: BorderRadius.circular(2),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),
            Text(
              'Withdraw Funds',
              style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                color: CupertinoColors.label.resolveFrom(context)
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _amountController,
              placeholder: 'Enter amount (KES)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(CupertinoIcons.money_dollar, color: CupertinoColors.systemGrey2.resolveFrom(context)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: CupertinoColors.systemGrey4.resolveFrom(context), width: 0.5)
              ),
              onChanged: (value) { // Clear error on change
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: cupertinoTheme.textTheme.caption1.copyWith(color: CupertinoColors.systemRed.resolveFrom(context)),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _handleWithdraw,
              child: _isLoading
                  ? const MyLoader() // Already adaptive, will show CupertinoActivityIndicator
                  : const Text('Withdraw'),
            ),
            const SizedBox(height: 16),
            Text(
              'The amount withdrawn will be credited to the phone number registered with your account. Contact admin for any queries.',
              textAlign: TextAlign.center,
              style: cupertinoTheme.textTheme.caption2.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
            ),
          ],
        ),
      ),
    );
  }
}
