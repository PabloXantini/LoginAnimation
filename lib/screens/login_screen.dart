import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  SMIBool? isChecking;
  SMINumber? numLook;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(emailFocus);
    passwordFocusNode.addListener(passwordFocus);
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(emailFocus);
    passwordFocusNode.removeListener(passwordFocus);
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void emailFocus() {
    isChecking?.change(emailFocusNode.hasFocus);
  }

  void passwordFocus() {
    isHandsUp?.change(passwordFocusNode.hasFocus);
  }

  void _onRiveInit(Artboard artboard) {
    StateMachineController? controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    );
    if (controller != null) {
      artboard.addController(controller);
      isChecking = controller.findSMI('isChecking') as SMIBool?;
      numLook = controller.findSMI('numLook') as SMINumber?;
      isHandsUp = controller.findSMI('isHandsUp') as SMIBool?;
      trigSuccess = controller.findSMI('trigSuccess') as SMITrigger?;
      trigFail = controller.findSMI('trigFail') as SMITrigger?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      //Reserve a space for frontals cameras (nudge)
      body: SafeArea(
        child: Column(
          children: [
            //Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              child: Text(
                'Rive + Flutter\nAnimated Guardian\nPolar Bear',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Animation
            Expanded(
              child: RiveAnimation.asset(
                'animated_login_character.riv',
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
            ),
            // Login panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Field of user
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return TextFormField(
                                  focusNode: emailFocusNode,
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    final textPainter = TextPainter(
                                      text: TextSpan(
                                        text: value,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      textDirection: TextDirection.ltr,
                                    )..layout();

                                    final textWidth = textPainter.width;
                                    final percentage =
                                        (textWidth / constraints.maxWidth) *
                                        100;

                                    numLook?.change(
                                      percentage.clamp(0.0, 100.0),
                                    );
                                  },
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Field of password
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: TextFormField(
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                emailFocusNode.unfocus();
                                passwordFocusNode.unfocus();
                                if (emailController.text == 'admin@mail.com' &&
                                    passwordController.text == '123456') {
                                  trigSuccess?.fire();
                                } else {
                                  trigFail?.fire();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[500],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
