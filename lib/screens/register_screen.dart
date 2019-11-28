import 'dart:convert';

import 'package:dgha/components/dgha_text_btn.dart';
import 'package:dgha/components/header_row.dart';
import 'package:dgha/components/input_textfield.dart';
import 'package:dgha/misc/dgha_api.dart';
import 'package:dgha/misc/styles.dart';
import 'package:dgha/screens/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = "Register Screen";
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ------------------------ NOTE: Variables
  String email;
  String passwordV1;
  String passwordV2;
  String loadingText = "Connecting...";

  double containerHeight;
  double marginHeight;
  double buttonMinWidth;

  bool passwordMatch = true;
  bool isLoading = false;
  bool showLoadingText = false;

  @override
  void initState() {
    super.initState();
  }

  void calcDimensions() {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;

    this.containerHeight = scrHeight;
    this.marginHeight = scrHeight * 0.05;
    this.buttonMinWidth = scrWidth * 0.45;
  }

  void signUp() async {
    setState(() {
      this.loadingText = "Connecting...";
      this.isLoading = true;
      this.showLoadingText = true;
    });
    if (this.passwordV1 == this.passwordV2) {
      try {
        print("TEST: ${DghaApi.currentClient}");
        //Create Account
        final Response newUser =
            await DghaApi.postAccount(this.email, this.passwordV1);

        if (newUser.statusCode == 201) {
          //Login
          await DghaApi.signIn(email: email, password: passwordV1);
          if (DghaApi.currentClient != null) {
            Navigator.of(context).pop();
            // await Navigator.of(context).pushNamed(ExploreScreen.id);
            // setState(() {
            //   this.isLoading = false;
            //   this.showLoadingText = false;
            // });
          }
        } else {
          List<dynamic> json = jsonDecode(newUser.body);
          setState(() {
            // NOTE: Handle error codes
            if (json[0]['code'] == "DuplicateUserName") {
              this.loadingText = "Account Already Exists";
            } else if (json[0]['code'] == "PasswordTooShort") {
              this.loadingText = "Password is too short";
            } else {
              this.loadingText = json[0]['code'];
            }
            this.isLoading = false;
          });
        }
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        this.loadingText = "Passwords do not match";
        this.isLoading = false;
      });
    }
  }

  Widget buildLoadingWidget() {
    if (this.showLoadingText) {
      return Container(
        child: Align(
          alignment: Alignment.center,
          child: Text(
            this.loadingText,
            style: Styles.h2Style,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            calcDimensions();
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: Styles.spacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: this.marginHeight * 0.5),
                          HeaderRow(text: "Sign Up"),
                          SizedBox(height: this.marginHeight * 0.7),

                          // NOTE: Connecting Text
                          buildLoadingWidget(),

                          SizedBox(
                            height: this.marginHeight * 0.5,
                          ),

                          // NOTE: Email
                          Container(
                            child: UserInputTextField(
                              textFieldLabel: "Email",
                              activePrefix: false,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: FontAwesomeIcons.solidEnvelope,
                              hintText: "Email",
                              onChange: (value) {
                                this.email = value;
                              },
                            ),
                          ),

                          SizedBox(height: this.marginHeight * 0.5),

                          // NOTE: Password V1
                          Container(
                            child: UserInputTextField(
                              textFieldLabel: "Password",
                              activePrefix: false,
                              prefixIcon: FontAwesomeIcons.lock,
                              hintText: "Password",
                              obscureText: true,
                              onChange: (value) {
                                this.passwordV1 = value;
                              },
                            ),
                          ),

                          SizedBox(height: this.marginHeight * 0.5),

                          // NOTE: Password V2
                          Container(
                            child: UserInputTextField(
                              textFieldLabel: "Confirm Password",
                              activePrefix: false,
                              prefixIcon: FontAwesomeIcons.lock,
                              hintText: "Confirm Password",
                              obscureText: true,
                              highlightRed: !passwordMatch,
                              onChange: (value) {
                                this.passwordV2 = value;
                                setState(() {
                                  if (passwordV1 != passwordV2)
                                    passwordMatch = false;
                                  else
                                    passwordMatch = true;
                                });
                              },
                            ),
                          ),

                          SizedBox(height: this.marginHeight * 0.5),

                          // NOTE: Terms and Condition
                          Container(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text:
                                          'By clicking "Register" you agree to the following '),
                                  TextSpan(
                                      text: 'Terms and Conditions.',
                                      style: Styles.linkStyle),
                                ],
                              ),
                              style: Styles.pStyle,
                            ),
                          ),

                          SizedBox(height: this.marginHeight * 0.5),

                          // NOTE: Register
                          Semantics(
                            button: true,
                            label: "Sign Up button",
                            hint: "Double tap to sign up",
                            excludeSemantics: true,
                            child: DghaTextButton(
                              minWidth: this.buttonMinWidth,
                              text: "Sign Up",
                              textStyle: Styles.yellowTxtBtnStyle,
                              colour: this.isLoading
                                  ? Styles.grey
                                  : Styles.midnightBlue,
                              onTap: () {
                                if (this.email != "" &&
                                    this.passwordV1 != "" &&
                                    this.passwordV2 != "" &&
                                    this.isLoading == false) {
                                  this.signUp();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: this.marginHeight * 0.5),

                    // NOTE: Skip
                    Semantics(
                      button: true,
                      label: "Skip button",
                      hint: "Double tap to skip sign up",
                      excludeSemantics: true,
                      child: DghaTextButton(
                        minWidth: this.buttonMinWidth,
                        text: "Skip",
                        textStyle: Styles.btnTextBlueUnderlineStyle,
                        colour: Styles.yellow,
                        onTap: () {
                          Navigator.pop(context);
                          // Navigator.of(context).pushNamed(ExploreScreen.id);
                        },
                        bottomMargin: this.marginHeight * 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
