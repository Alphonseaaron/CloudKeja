import 'dart:io';
import 'package:flutter/material.dart';
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
  String? profile, name, idnumber,  email, password, phone, passwordConfrimation;
  // late File profile;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  // Function to select and display profile picture
  _selectProfilePic() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profile = image as String?;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
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
                        Center(
                          child: profile == null
                              ? CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey[200],
                            child: IconButton(
                              icon: Icon(Icons.add_a_photo),
                              onPressed: _selectProfilePic,
                            ),
                          )
                              : CircleAvatar(radius: 80,
                            backgroundImage: FileImage(profile as File),
                            child: IconButton(
                              icon: Icon(Icons.add_a_photo),
                              onPressed: _selectProfilePic,
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
                                name = val;
                              });
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your full names';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.account_circle_rounded),
                              hintText: 'Full Name As In Your ID Number',
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
                      if (profile != null) {
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
                            profile: profile,
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
                      }
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
      ),
    );
  }
}
