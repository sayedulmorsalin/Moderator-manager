import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mod_maneger_v3/pages/admin/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  String admin_key = "", admin_email = "", admin_pass = "",user="";
  bool obscurePassword = true,
      isLoading = false,
      rememberMe = false;

  TextEditingController adminkeycontroller = TextEditingController();
  TextEditingController adminemailcontroller = TextEditingController();
  TextEditingController adminpasscontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }
  Future<void> _loadSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      admin_email = prefs.getString('email') ?? "";
      admin_pass = prefs.getString('password') ?? "";
      rememberMe = prefs.getBool('isLoggedIn') ?? false;
      adminemailcontroller.text = admin_email;
      adminpasscontroller.text=admin_pass;

    });
  }
  Future<void> _saveCredentials(String email, String password,String user, bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('user', user);
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  adminlogin() async {
    if (adminkeycontroller.text.isNotEmpty &&
        adminemailcontroller.text.isNotEmpty &&
        adminpasscontroller.text.isNotEmpty) {
      isLoading= true;
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: admin_email, password: admin_pass);
        if (rememberMe) {
          await _saveCredentials(adminemailcontroller.text, adminpasscontroller.text,"admin", true);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Admin login successfully!",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        )));
        isLoading=false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AdminHome()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "The email you provide is not found",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          )));
        } else if (e.code == 'wrong password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "Wrong password provided by user",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          )));
        }
      }
      isLoading=false;
    }
    isLoading=false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Admin ",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Login ",
              style: TextStyle(
                  color: Colors.purple,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Form",
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20.0, top: 30.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin key",
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
                        return 'Please enter admin key';
                      } else if (value != 'chandrapur@siam#dadu') {
                        return 'The key is wrong';
                      }
                      return null;
                    },
                    controller: adminkeycontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Admin email",
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
                        return 'Please enter admin email';
                      }
                      return null;
                    },
                    controller: adminemailcontroller,
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
                    controller: adminpasscontroller,
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
                Center(

                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              admin_key = adminkeycontroller.text;
                              admin_email = adminemailcontroller.text;
                              admin_pass = adminpasscontroller.text;
                            });
                            adminlogin();
                          }
                        },
                        child: isLoading ? CircularProgressIndicator(color: Colors.green):
                        Text(
                          "Submit",
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
