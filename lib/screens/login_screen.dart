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
  SMINumber? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  Widget build(BuildContext context) {
    //Screen size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      //Reserve a space for frontals cameras (nudge)
      body: SafeArea(
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
                    _numLook = _controller!.findSMI('numLook') as SMINumber;
                    _trigSuccess = _controller!.findSMI('trigSuccess') as SMITrigger;
                    _trigFail = _controller!.findSMI('trigFail') as SMITrigger;
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value){
                  if(_isHandsUp!=null){
                    _isHandsUp!.change(false);
                  }
                  if(_isChecking == null) return;
                  _isChecking!.change(true);
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value){
                  if(_isChecking!=null){
                    _isChecking!.change(false);
                  }
                  if(_isHandsUp == null) return;
                  _isHandsUp!.change(true);
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
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
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
