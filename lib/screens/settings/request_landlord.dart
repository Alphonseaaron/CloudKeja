import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/constants.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

import '../../models/user_model.dart';
import '../auth/theme.dart';

class RequestLandlord extends StatefulWidget {
  const RequestLandlord({Key? key}) : super(key: key);

  @override
  State<RequestLandlord> createState() => _RequestLandlordState();
}

class _RequestLandlordState extends State<RequestLandlord> {
  final _formKey = GlobalKey<FormState>();
  late final String? bankBusinessNumber;
  late final String? bankNumber;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text(
            'Request to be a Landlord',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 100,
            child: Lottie.asset('assets/admin.json'),
          ),
          const SizedBox(
            height: 30,
          ),
          Form(
            key: _formKey,
            child: Column(
                children:[
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: textWhiteGrey,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          bankNumber = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter your bank account to receive payments';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_circle_rounded),
                        hintText: 'Bank Account Number',
                        hintStyle: heading6.copyWith(color: textGrey),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: textWhiteGrey,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          bankBusinessNumber = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter the bank business number for Mpesa payments';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_circle_rounded),
                        hintText: 'Bank business number for Mpesa payments',
                        hintStyle: heading6.copyWith(color: textGrey),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            'You will have to wait for an admin to approve your details',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  isLoading = true;
                });
                final uid = FirebaseAuth.instance.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'bankBusinessNumber': bankBusinessNumber,
                  'bankNumber': bankNumber,
                });
                await Provider.of<AdminProvider>(context, listen: false)
                    .makeLandlord(uid, false);

                Navigator.of(context).pop();
              }
            },
            child: const Text('Request'),
            style: ElevatedButton.styleFrom(
              primary: kPrimaryColor,
              textStyle: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// class RequestLandlord extends StatelessWidget {
//   const RequestLandlord({Key? key}) : super(key: key);
//   final _formKey = GlobalKey<FormState>();
//   final String? bankBusinessNumber;
//   final String? bankNumber;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         children: [
//           const Text(
//             'Request to be a Landlord',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           SizedBox(
//             height: 100,
//             child: Lottie.asset('assets/admin.json'),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           const Text(
//             'You will have to wait for an admin to approve your details',
//             style: TextStyle(
//               color: Colors.grey,
//             ),
//           ),
//           Form(
//             key: _formKey,
//               child: Column(
//                 children:[
//                   const SizedBox(
//                     height: 15,
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: textWhiteGrey,
//                       borderRadius: BorderRadius.circular(14.0),
//                     ),
//                     child: TextFormField(
//                       onChanged: (val) {
//                           bankNumber = val;
//                       },
//                       validator: (val) {
//                         if (val!.isEmpty) {
//                           return 'Please enter your bank account to receive payments';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.account_circle_rounded),
//                         hintText: 'Bank Account Number',
//                         hintStyle: heading6.copyWith(color: textGrey),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: textWhiteGrey,
//                       borderRadius: BorderRadius.circular(14.0),
//                     ),
//                     child: TextFormField(
//                       onChanged: (val) {
//                           bankBusinessNumber = val;
//                       },
//                       validator: (val) {
//                         if (val!.isEmpty) {
//                           return 'Please enter the bank business number for Mpesa payments';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.account_circle_rounded),
//                         hintText: 'Bank business number for Mpesa payments',
//                         hintStyle: heading6.copyWith(color: textGrey),
//                         border: const OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]
//               ),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final user = UserModel(
//                   bankBusinessNumber: bankBusinessNumber,
//                   bankNumber : bankNumber,
//                 );
//                 final uid = FirebaseAuth.instance.currentUser!.uid;
//                 await Provider.of<AdminProvider>(context, listen: false)
//                     .makeLandlord(uid, false);
//
//                 Navigator.of(context).pop();
//               }
//             },
//             child: const Text('Request'),
//             style: ElevatedButton.styleFrom(
//               primary: kPrimaryColor,
//               textStyle: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
