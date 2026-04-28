import 'dart:async'; //3.1 Import Timer

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Controller to show/hide password
  bool _obscureText = true;

  //Central logic of animation
  StateMachineController? _controller;
  //State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMINumber? _numLook; //2.2 variable for tracking the bear look 
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  //1.1 Create variables for FocusNode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  //3.2 Timer for stop the look when stop writing
  Timer? _typingDebounce;
  //4.1 Controllers for keep text
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  //4.2 Show Errors on UI
  String? emailError;
  String? passwordError;
  //4.3 Validators
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }
  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }
  //4.4 Action of button
  void _onLogin(){
    // Get the string when write the user
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    // Calculate possible errores
    final emailUIError = isValidEmail(email) ? null : 'Email inválido';
    final passwordUIError = isValidPassword(password) ? null : 'Contraseña inválida'; 
    //4.5 Notify changes on UI
    setState(() {
      emailError = emailUIError;
      passwordError = passwordUIError; 
    });
    //4.6 Close keyboard and hands down
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;
    //4.7 Activate the triggers
    if(emailUIError==null && passwordUIError ==null){
      _trigSuccess?.fire();
    }else{
      _trigFail?.fire();
    }
  }
  //1.2 Add listener
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener((){
      if(_emailFocusNode.hasFocus){
        //Check is not null
        if(_isHandsUp != null){
          //Hands down in email
          _isHandsUp?.change(false);
          //2.2 Neutral look
          _numLook?.value = 50.0;
        }
      }
    });
    _passwordFocusNode.addListener((){
      //Hands up when is in password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }
  //1.4 Release memory when exit on the screen
  @override
  void dispose() {
    super.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }
  @override
  Widget build(BuildContext context) {
    //Screen size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      //Reserve a space for frontals cameras (nudge)
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation
                SizedBox(
                  width: size.width,
                  height: size.height * 0.4,
                  child: RiveAnimation.asset(
                    'assets/animated_login_character.riv',
                    //fit: BoxFit.contain,
                    stateMachines: ["Login Machine"],
                    //On init load the animation
                    onInit: (artboard){
                      _controller = StateMachineController.fromArtboard(artboard, "Login Machine");
                      //Verify if load correctly
                      if(_controller == null) return;
                      artboard.addController(_controller!);
                      _isChecking = _controller!.findSMI('isChecking') as SMIBool;
                      _isHandsUp = _controller!.findSMI('isHandsUp') as SMIBool;
                      _numLook = _controller!.findSMI('numLook') as SMINumber; //1.3 bind numLook
                      _trigSuccess = _controller!.findSMI('trigSuccess') as SMITrigger;
                      _trigFail = _controller!.findSMI('trigFail') as SMITrigger;
                    },
                  ),
                ),
                //Email
                const SizedBox(height: 10),
                TextField(
                  //4.8 bind controller
                  controller: emailCtrl,
                  //bind focus to textfield
                  focusNode: _emailFocusNode,
                  onChanged: (value){
                    if(_isHandsUp!=null){
                      _isHandsUp!.change(false);
                    }
                    if(_isChecking == null) return;
                    _isChecking!.change(true);
                    // 2.4 Implement logic
                    // Adjust from 0 to 100
                    final double look = (value.length / 80.0 * 100.0).clamp(0, 100);
                    _numLook?.value = look;
                    // 3.3 Implment debounce (timer)
                    // Cancel any timer existent
                    _typingDebounce?.cancel();
                    _typingDebounce = Timer(const Duration(seconds: 3), (){
                      //if closes the screen
                      if(!mounted) return;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    // 4.9 Show error
                    errorText: emailError,
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordCtrl,
                  focusNode: _passwordFocusNode,
                  onChanged: (value){
                    if(_isChecking!=null){
                      //_isChecking!.change(false);
                    }
                    if(_isHandsUp == null) return;
                    //_isHandsUp!.change(true);
                  },
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    errorText: passwordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }, 
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(height: 10),
                //Text of forgot password
                SizedBox(
                  width: size.width,
                  child: const Text(
                    "Forgot password",
                    //Align to right
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      decoration: TextDecoration.underline
                    ),
                  ),
                ),
                SizedBox(height: 10),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: _onLogin, 
                  child: Text(
                    'Login', 
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // No Account?
                SizedBox(
                  width: size.width,
                  child: Row(
                    children: [
                      const Text('Don\'t have account? '),
                      TextButton(
                        onPressed: (){}, 
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
