import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/constants.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

class RequestLandlord extends StatelessWidget {
  const RequestLandlord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              final uid = FirebaseAuth.instance.currentUser!.uid;
              await Provider.of<AdminProvider>(context, listen: false)
                  .makeLandlord(uid, false);

              Navigator.of(context).pop();
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
