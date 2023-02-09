//import 'package:mpesa/mpesa.dart';

//Mpesa mpesa = Mpesa(
//  clientKey: "KwxqAJ8AqXc0KNwsdhjYT66tvp5SnkEL",
//  clientSecret: "2elwsWNTGnCA2nUL",
//  passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
//  environment: "sandbox",
//);

//Future<void> mpesaPayment({String? phone, double? amount}) async {
//  await mpesa.lipaNaMpesa(
//      phoneNumber: phone!,
//      amount: amount!,
//      accountReference: 'CloudKeja',
//      businessShortCode: "174379",
//      callbackUrl:
//          "https://us-central1-spacescape.cloudfunctions.net/lmno_callback_url")
//      .then((result) {})
//      .catchError((error) {});
  // .catchError((error) {});
// }

import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';


  int _getCommissionRate(int amount) {
    int commission;
    if (amount >= 0 && amount <= 50000) {
      commission = 50;
    } else if (amount > 50000 && amount <= 100000) {
      commission = 60;
    } else if (amount > 100000 && amount <= 150000) {
      commission = 70;
    } else if (amount > 150000 && amount <= 200000) {
      commission = 80;
    } else if (amount > 200000 && amount <= 300000) {
      commission = 90;
    } else if (amount > 300000) {
      commission = 100;
    } else {
      commission= 0;
    }
    return commission;
  }

Future<void> mpesaPayment({String? phone, String? bankNumber, String? bankBusinessNumber, int? amount}) async {
    MpesaFlutterPlugin.setConsumerKey('KwxqAJ8AqXc0KNwsdhjYT66tvp5SnkEL');
    MpesaFlutterPlugin.setConsumerSecret('2elwsWNTGnCA2nUL');
    int commissionAmount = _getCommissionRate(amount!);
    int landlordAmount = amount - commissionAmount;

    // Deduct commission to your till number (174359)
    MpesaFlutterPlugin.initializeMpesaSTKPush(
      businessShortCode: "174379",
      transactionType: TransactionType.CustomerBuyGoodsOnline,
      amount: commissionAmount,
      partyA: phone!,
      partyB: "174379",
      callBackURL: Uri.parse("https://us-central1-spacescape.cloudfunctions.net/lmno_callback_url"),
      accountReference: "CloudKeja",
      transactionDesc: "Deduct commission",
      phoneNumber: phone,
      baseUri: Uri.parse("https://sandbox.safaricom.co.ke"),
      passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
    ).then((value) {
      // Pay landlord
      MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: bankBusinessNumber!,
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: landlordAmount,
        partyA: phone,
        partyB: bankNumber!,
        callBackURL: Uri.parse("https://us-central1-spacescape.cloudfunctions.net/lmno_callback_url"),
        accountReference: "CloudKeja",
        transactionDesc: "Pay landlord",
        phoneNumber: phone,
        baseUri: Uri.parse("https://sandbox.safaricom.co.ke"),
        passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
      ).then((value) {
        Fluttertoast.showToast(
          msg: "Payment Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: "Payment to Landlord Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "Payment Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("Payment Page"),
  //     ),
  //     body: Container(
  //       padding: EdgeInsets.all(16),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           children: <Widget>[
  //             TextFormField(
  //               decoration: InputDecoration(labelText: "Business Number"),
  //               validator: (value) {
  //                 if (value!.isEmpty) {
  //                   return "Please enter a valid business number";
  //                 }
  //                 return null;
  //               },
  //               onSaved: (value) => _businessNumberController.text,
  //             ),
  //             TextFormField(
  //               decoration: InputDecoration(labelText: "Bank Account Number"),
  //               validator: (value) {
  //                 if (value!.isEmpty) {
  //                   return "Please enter a valid bank account number";
  //                 }
  //                 return null;
  //               },
  //               onSaved: (value) => _bankAccountNumberController.text,
  //             ),
  //             TextFormField(
  //               decoration: InputDecoration(labelText: "Amount"),
  //               validator: (value) {
  //                 if (value!.isEmpty) {
  //                   return "Please enter a valid amount";
  //                 }
  //                 return null;
  //               },
  //               onSaved: (value) => _amountController.text,
  //             ),
  //             SizedBox(
  //               height: 16,
  //             ),
  //             Container(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blueAccent
  //               ),
  //                 onPressed: () {
  //                   if (_formKey.currentState!.validate()) {
  //                     _formKey.currentState!.save();
  //                     _getCommissionRate;
  //                     _onPaymentSuccess;
  //                   }
  //                 },
  //                 child: Text("Submit"),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

