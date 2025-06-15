import 'package:flutter/widgets.dart'; // For StatelessWidget, BuildContext, Key
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/finances/widget/withdraw_widget_material_content.dart';
import 'package:cloudkeja/screens/landlord/finances/widget/withdraw_widget_cupertino_content.dart';

// Renamed original WithdrawWidget to WithdrawWidgetRouter to act as the router
class WithdrawWidgetRouter extends StatelessWidget {
  final double? balance;

  const WithdrawWidgetRouter({
    Key? key,
    this.balance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    // The content widgets (MaterialContent and CupertinoContent) are designed
    // to be the direct children of showModalBottomSheet's builder (for Material)
    // or the child of a Container within showCupertinoModalPopup's builder (for Cupertino).
    // This router returns the appropriate *content* widget.
    // The presentation logic (showModalBottomSheet vs showCupertinoModalPopup)
    // will be handled by the calling widgets (e.g., FinanceTopMaterial/FinanceTopCupertino).

    if (platformService.useCupertino) {
      return WithdrawWidgetCupertinoContent(
        key: key, // Pass key
        balance: balance,
      );
    } else {
      // The Material version's DraggableScrollableSheet and GestureDetectors for dismissal
      // were part of the original WithdrawWidget. For a pure content widget, they should be
      // part of how it's shown.
      // For this refactor, WithdrawWidgetMaterialContent contains the core UI.
      // If the draggable/dismissal behavior is desired, the caller (FinanceTopMaterial)
      // would need to wrap WithdrawWidgetMaterialContent in showModalBottomSheet with those features.
      // The current WithdrawWidgetMaterialContent is simplified to be just the inner content.
      return WithdrawWidgetMaterialContent(
        key: key, // Pass key
        balance: balance,
      );
    }
  }
}
