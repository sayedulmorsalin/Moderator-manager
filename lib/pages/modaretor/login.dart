import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mod_maneger_v3/pages/modaretor/home.dart';
import 'package:mod_maneger_v3/pages/modaretor/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String mod_email = "", mod_pass = "",user="";
  bool rememberMe = false;
  bool isLoading = false;
  bool obscurePassword = true;
  TextEditingController modemailcontroller = TextEditingController();
  TextEditingController modpasscontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mod_email = prefs.getString('email') ?? "";
      mod_pass = prefs.getString('password') ?? "";
      rememberMe = prefs.getBool('isLoggedIn') ?? false;
      modemailcontroller.text = mod_email;
      modpasscontroller.text = mod_pass;
    });
  }

  Future<void> _saveCredentials(String email, String password,String user, bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('user', user);
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> modlogin() async {
    if (modemailcontroller.text.isNotEmpty && modpasscontroller.text.isNotEmpty) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: modemailcontroller.text,
          password: modpasscontroller.text,
        );

        // Save the credentials and login status
        if (rememberMe) {
          await _saveCredentials(modemailcontroller.text, modpasscontroller.text,"mod", true);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login successful!",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        );

        // Navigate to Home
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred. Please try again.";
        if (e.code == 'user-not-found') {
          errorMessage = "The email you provided is not found.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Wrong password provided.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login ",
              style: TextStyle(
                  color: Colors.blue, fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            Text(
              "form",
              style: TextStyle(
                  color: Colors.orange, fontSize: 30.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  decoration: getTextFieldDecoration(),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}").hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    controller: modemailcontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Password",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  decoration: getTextFieldDecoration(),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    controller: modpasscontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscurePassword,
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    Text("Remember Me")
                  ],
                ),
                SizedBox(height: 20.0),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        await modlogin();
                      }
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                    },
                    child: Text("Forgot Password?"),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                      // Navigate to registration screen
                    },
                    child: Text("New User? Register Here"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration getTextFieldDecoration() {
    return BoxDecoration(
      color: Colors.white54,
      border: Border.all(
        width: 4, // Border width
        color: Colors.black12, // Border color
      ),
      borderRadius: BorderRadius.circular(30),
    );
  }
}
