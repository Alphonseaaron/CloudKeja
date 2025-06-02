import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/models/payment_model.dart';
import 'package:cloudkeja/widgets/tiles/payment_history_tile_cupertino.dart';
import 'package:cloudkeja/widgets/tiles/payment_history_tile_material.dart';

class PaymentHistoryTileRouter extends StatelessWidget {
  final PaymentModel paymentData;
  final bool isSkeleton; // Pass through isSkeleton if needed by Material version

  const PaymentHistoryTileRouter({
    Key? key,
    required this.paymentData,
    this.isSkeleton = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      // Cupertino version currently doesn't use isSkeleton directly in its own props,
      // but if it did, it would be passed here.
      // It handles its own visual representation based on actual data.
      return PaymentHistoryTileCupertino(paymentData: paymentData);
    } else {
      return PaymentHistoryTileMaterial(paymentData: paymentData, isSkeleton: isSkeleton);
    }
  }
}
