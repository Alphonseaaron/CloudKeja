import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/constants.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/auth/widgets/custom_checkbox.dart';
import 'package:cloudkeja/screens/auth/widgets/primary_button.dart';
import 'package:cloudkeja/screens/home/my_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool passwordVisible = false;
  bool passwordConfrimationVisible = false;
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }
  String? name, idnumber,  email, password, phone, passwordConfrimation;
  // File? _imageFile;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  // final ImagePicker _picker = ImagePicker();
  // Function to select and display profile picture
  // Future pickImage() async {
  //   try {
  //     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if (image == null) return;
  //     final imageTemporary = File(image.path);
  //     this.image = imageTemporary;
  //     setState(() => this.image = imageTemporary);
  //   } on PlatformException catch (e) {
  //     print('Failed to pick image: $e');
  //   }
  //   final bytes = await image!.readAsBytes();
  //   print (imageBytes);
  //   String base64Image = base64Encode(imageBytes);
  //   print (base64Image);
  // }


//   Future _pickImageBase64() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//
//     Uint8List imagebyte = await image.readAsBytes();
//     String _base64 = base64.encode(imagebyte);
//     print (_base64);
//
//     final imageTemporaryPath = File(image.path);
//     setState(() {
//       this._imageFile = imageTemporaryPath;
//     });
//     print (imageTemporaryPath);
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register new\naccount',
                        style: heading2.copyWith(color: textBlack),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Image.asset(
                        'assets/images/accent.png',
                        width: 99,
                        height: 4,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  Form(
                    child: Column(
                      children: [
                        // Center(
                        //   child: _imageFile == null
                        //       ?  Container(
                        //       padding: const EdgeInsets.all(5),
                        //       decoration: BoxDecoration(
                        //         color: Theme.of(context).cardColor,
                        //         shape: BoxShape.circle,
                        //       ),
                        //       child: CircleAvatar(
                        //         radius: 80,
                        //         backgroundColor: Colors.grey[200],
                        //         child: Stack(
                        //             children: [
                        //               Align(
                        //                 alignment: Alignment.bottomRight,
                        //                 child: CircleAvatar(
                        //                   radius: 20,
                        //                   backgroundColor: Colors.blueAccent,
                        //                   child: IconButton(
                        //                     icon: Icon(Icons.add_a_photo),
                        //                     onPressed: _pickImageBase64,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ]
                        //         ),
                        //       )
                        //   )
                        //       : Container(
                        //     padding: const EdgeInsets.all(5),
                        //     decoration: BoxDecoration(
                        //       color: Theme.of(context).cardColor,
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: CircleAvatar(
                        //       radius: 80,
                        //       backgroundImage: FileImage(
                        //         _imageFile!,
                        //       ),
                        //       child: Stack(
                        //           children: [
                        //             Align(
                        //               alignment: Alignment.bottomRight,
                        //               child: CircleAvatar(
                        //                 radius: 20,
                        //                 backgroundColor: Colors.blueAccent,
                        //                 child: IconButton(
                        //                   icon: Icon(Icons.edit),
                        //                   onPressed: _pickImageBase64,
                        //                 ),
                        //               ),
                        //             ),
                        //           ]
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                                name = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Full names according to Mpesa';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.account_circle_rounded),
                              hintText: 'Full names as they appear in your ID Number',
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
                                idnumber = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your ID number';
                              }
                              if (val.length < 7 || val.length > 8) {
                                return 'Please enter a valid ID number';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.badge),
                              hintText: 'ID Number',
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
                                phone = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (val.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone_iphone),
                              hintText: 'Phone Number',
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
                                email = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!val.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email',
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
                                password = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            obscureText: !passwordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.key),
                              hintText: 'Password',
                              hintStyle: heading6.copyWith(color: textGrey),
                              suffixIcon: IconButton(
                                color: textGrey,
                                splashRadius: 1,
                                icon: Icon(passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: togglePassword,
                              ),
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
                                passwordConfrimation = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please confirm your password';
                              }

                              if (val != password) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            obscureText: !passwordConfrimationVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.key),
                              hintText: 'Password Confirmation',
                              hintStyle: heading6.copyWith(color: textGrey),
                              suffixIcon: IconButton(
                                color: textGrey,
                                splashRadius: 1,
                                icon: Icon(passwordConfrimationVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () {
                                  setState(() {
                                    passwordConfrimationVisible =
                                    !passwordConfrimationVisible;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CustomCheckbox(),
                      const SizedBox(
                        width: 12,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By creating an account, you agree to our',
                            style: regular16pt.copyWith(color: textGrey),
                          ),
                          Text(
                            'Terms & Conditions',
                            style: regular16pt.copyWith(color: kPrimaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomPrimaryButton(
                    buttonColor: kPrimaryColor,
                    onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });

                          final user = UserModel(
                            idnumber: idnumber,
                            email: email,
                            password: password,
                            name: name,
                            phone: phone,
                            isAdmin: false,
                            isLandlord: false,
                            profile: 'https://firebasestorage.googleapis.com/v0/b/cloudkeja-d7e6b.appspot.com/o/userData%2FprofilePics%2Favatar.png?alt=media&token=d41075f9-6611-40f3-9c46-80730625530e',
                            rentedPlaces: [],
                            wishlist: [],
                          );

                          try {
                            await Provider.of<AuthProvider>(context,
                                listen: false)
                                .signUp(user);
                            Get.off(() => const MainPage());
                          } catch (error) {
                            setState(() {
                              isLoading = false;
                            });
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('An error occurred'),
                                  content: Text(error.toString()),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Okay'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    )
                                  ],
                                ));
                          }
                        }
                      // }
                    },
                    textValue: 'Register',
                    textColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: regular16pt.copyWith(color: textGrey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: Text(
                          'Login',
                          style: regular16pt.copyWith(color: kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
