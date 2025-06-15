import 'package:flutter/widgets.dart'; // For StatelessWidget, BuildContext, Key
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel type
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/finances/widget/finance_top_material.dart';
import 'package:cloudkeja/screens/landlord/finances/widget/finance_top_cupertino.dart';

// Renamed original FinanceTop to FinanceTopRouter to act as the router
class FinanceTopRouter extends StatelessWidget {
  final UserModel? user;
  final bool isLoadingUser;

  const FinanceTopRouter({
    Key? key,
    this.user,
    this.isLoadingUser = true, // Default to true, parent should pass actual state
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return FinanceTopCupertino(
        key: key, // Pass key
        user: user,
        isLoadingUser: isLoadingUser,
      );
    } else {
      return FinanceTopMaterial(
        key: key, // Pass key
        user: user,
        isLoadingUser: isLoadingUser,
      );
    }
  }
}
