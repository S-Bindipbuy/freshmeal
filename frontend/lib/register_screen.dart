import 'package:flutter/material.dart';
import 'package:frontend/dashboard_screen.dart';
import 'package:frontend/login_screen.dart';

class registerScreen extends StatelessWidget{
  const registerScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: 20.0,right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Container(
                child: Text("Register",style: TextStyle(fontSize: 64,fontFamily: 'Poetsen',color: Color(0xFFFFA12E)),),
              ),
              Container(
                width: double.infinity,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFFFFA12E), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFFFFA12E), width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 16.0),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFFFFA12E), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFFFFA12E), width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 16.0),
                  ),
                ),
              ),
              Container(

                width: double.infinity,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFFFFA12E), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Color(0xFFFFA12E), width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 16.0),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: [
                          Checkbox(
                            tristate: true,
                            value: true,
                            onChanged: (bool? value) {
                            },
                          ),
                          Text("Remember Password"),
                        ],
                      ),
                    ),
                    Text("Forgot Passwor"),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const dashboardScreen()),
                  );
                },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF79926),
                    padding: EdgeInsets.all(12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    )),
                    child: Text("Register",style: TextStyle(fontSize: 20,color: Color(0xFFFFFFFF),fontFamily: "Poetsen"))),
              ),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("If your have account"),
                    TextButton(onPressed: ()=>{
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const loginScreen()),
                      )
                    }, child: Text("Login"))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
