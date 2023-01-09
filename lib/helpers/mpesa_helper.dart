import 'package:mpesa/mpesa.dart';

Mpesa mpesa = Mpesa(
  clientKey: "KwxqAJ8AqXc0KNwsdhjYT66tvp5SnkEL",
  clientSecret: "2elwsWNTGnCA2nUL",
  passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
  environment: "sandbox",
);

Future<void> mpesaPayment({String? phone, double? amount}) async {
  await mpesa.lipaNaMpesa(
      phoneNumber: phone!,
      amount: amount!,
      accountReference: 'CloudKeja',
      businessShortCode: "174379",
      callbackUrl:
          "https://us-central1-spacescape.cloudfunctions.net/lmno_callback_url");
  // .catchError((error) {});
}
