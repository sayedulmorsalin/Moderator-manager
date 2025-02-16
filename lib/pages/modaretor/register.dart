import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mod_maneger_v3/pages/modaretor/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String mod_key = "",
      mod_name = "",
      mod_email = "",
      mod_pass = "",
      mod_pass2 = "",
      user= "";
  bool obscurePassword = true,
      obscurePassword2 = true,
      withdraw_request = false,
      isLoading = false,
      rememberMe = false;


  int total_sell = 0,
      total_selltk = 0,
      total_commission = 0,
      total_withdraw = 0,
      available_balance = 0,
      withdraw_amount = 0;

  TextEditingController modkeycontroller = new TextEditingController();
  TextEditingController modnamecontroller = new TextEditingController();
  TextEditingController modemailcontroller = new TextEditingController();
  TextEditingController modpasscontroller = new TextEditingController();
  TextEditingController modpass2controller = new TextEditingController();

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
    });
  }
  Future<void> _saveCredentials(String email, String password,String user, bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('user', user);
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  registration() async {
    setState(() {
      isLoading = true;  // Start loading indicator
    });

    if (modkeycontroller.text != "" &&
        modnamecontroller.text != "" &&
        modemailcontroller.text != "" &&
        modpasscontroller.text != "" &&
        modpass2controller.text != "") {

      try {
        // Firebase Auth registration
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: modemailcontroller.text, password: modpasscontroller.text);
        if (rememberMe) {
          await _saveCredentials(modemailcontroller.text, modpasscontroller.text,"mod", true);
        }
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Registered successfully!",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ));

        // Proceed to add moderator details to database
        Map<String, dynamic> modinfomap = {
          "Mod_email": modemailcontroller.text,
          "Mod_name": modnamecontroller.text,
          "Total_sell": total_sell,
          "Total_selltk": total_selltk,
          "Total_commission": total_commission,
          "Total_withdraw": total_withdraw,
          "Available_balance": available_balance,
          "Withdraw_request": withdraw_request,
          "Withdraw_amount": withdraw_amount,
          "Mod_password": mod_pass,
        };

        await database()
            .moderatordetails(modinfomap, modemailcontroller.text)
            .then((onValue) {
          // Show success for database operation
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Moderator details saved successfully."),
          ));

          setState(() {
            isLoading = false;  // Stop loading indicator
          });

          // Navigate to Home page
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;  // Stop loading indicator on error
        });

        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("The password you provided is too weak"),
          ));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Account Already Exists"),
          ));}
          else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        }
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
              "Register ",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "form",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Moderator Key",
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
                        return 'Please enter moderator key';
                      } else if (value != 'mod@dadu#mor') {
                        return 'The key is wrong';
                      }
                      return null;
                    },
                    controller: modkeycontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Moderator Name",
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
                        return 'Please enter moderator name';
                      }
                      return null;
                    },
                    controller: modnamecontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
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
                      }
                      return null;
                    },
                    controller: modemailcontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Set password",
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
                        return 'Please enter moderators password';
                      }
                      return null;
                    },
                    controller: modpasscontroller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Re-enter password",
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
                        return 'Please enter moderator password';
                      } else if (value != modpasscontroller.text) {
                        return 'Passwords do not match. Please re-enter the password';
                      }
                      return null;
                    },
                    controller: modpass2controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword2
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword2 = !obscurePassword2;
                          });
                        },
                      ),
                    ),
                    obscureText: obscurePassword2,
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

                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              mod_key = modkeycontroller.text;
                              mod_name = modnamecontroller.text;
                              mod_email = modemailcontroller.text;
                              mod_pass = modpasscontroller.text;
                              mod_pass2 = modpass2controller.text;
                            });
                          }
                          registration();
                        },

                        child:
                        isLoading
                            ? CircularProgressIndicator(color: Colors.green):
                        Text(

                          "Create",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        )),
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
