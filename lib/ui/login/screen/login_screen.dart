import 'package:evently_c19/core/resources/app_constants.dart';
import 'package:evently_c19/core/resources/dialog_utils.dart';
import 'package:evently_c19/core/resources/routes_manager.dart';
import 'package:evently_c19/core/resources/strings_manager.dart';
import 'package:evently_c19/core/reusable_components/custom_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/resources/assets_manager.dart';
import '../../../core/reusable_components/custom_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          AssetsManager.logo,
          height: 27,
          fit: BoxFit.fitHeight,
          color: Theme
              .of(context)
              .colorScheme
              .primary,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringsManager.loginToYourAccount,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24),
                CustomField(
                  validation: (value) {
                    if (value == null || value.isEmpty) {
                      return StringsManager.emailEmpty;
                    }
                    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
                      return StringsManager.emailInvalid;
                    }
                    return null;
                  },
                  controller: emailController,
                  hint: StringsManager.emailHint,
                  prefixPath: AssetsManager.email,
                  keyboard: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                CustomField(
                  validation: (value) {
                    if (value == null || value.isEmpty) {
                      return StringsManager.passwordEmpty;
                    }
                    if (value.length < 8) {
                      return StringsManager.passwordWeak;
                    }
                    return null;
                  },
                  isObscure: true,
                  controller: passwordController,
                  hint: StringsManager.passwordHint,
                  prefixPath: AssetsManager.lock,
                  keyboard: TextInputType.visiblePassword,
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutesManager.forgetpassRouteName,
                      );
                    },
                    child: Text(
                      StringsManager.forgetPassAsk,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium,
                    ),
                  ),
                ),
                SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  child: CustomBtn(
                    title: StringsManager.login,
                    onClick: () {
                      if (formKey.currentState?.validate() ?? false) {
                        login();
                      }
                    },
                  ),
                ),
                SizedBox(height: 48),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      AssetsManager.logo,
                      height: 24,
                    ),
                    label: Text("Sign in with Google"),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${StringsManager.dontHaveAcc} ",
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          RoutesManager.signupRouteName,
                        );
                      },
                      child: Text(
                        StringsManager.signup,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  login() async {
    try {
      DialogUtils.showLoadingDialog(context);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, RoutesManager.homeRouteName);
      print(credential.user?.uid);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      if (e.code == 'user-not-found') {
        DialogUtils.showMessageDialog(
          context: context,
          content: "No user found for that email.",
          actionTitle: "Ok",
          actionPress: () {
            Navigator.of(context).pop();
          },
        );
      } else if (e.code == 'wrong-password') {
        DialogUtils.showMessageDialog(
          context: context,
          content: "Wrong password provided for that user.",
          actionTitle: "Ok",
          actionPress: () {
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      print("sign in exception : $e");
    }
  }
  signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      DialogUtils.showLoadingDialog(context);
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, RoutesManager.homeRouteName);
    } catch (e) {
      print("Google sign in error: $e");
    }
  }
}
