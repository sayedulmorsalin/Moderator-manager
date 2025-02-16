import 'package:flutter/material.dart';
import 'package:mod_maneger_v3/pages/modaretor/login.dart';
import 'package:mod_maneger_v3/pages/modaretor/register.dart';

import '../admin/admin_login.dart';
import '../admin/admin_register.dart';

class LandPage extends StatefulWidget {
  const LandPage({super.key});

  @override
  State<LandPage> createState() => _LandPageState();
}


class _LandPageState extends State<LandPage> {
  String dropdownValue = "Moderator"; // Initial dropdown value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Dadu ",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Khelaghor",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: <String>["Admin", "Moderator"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Text in bold
                  ),
                ),
              );
            }).toList(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: Container(), // Removes the underline
            dropdownColor: Theme.of(context).appBarTheme.backgroundColor, // Matches AppBar color
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
          child: Column(
            children: [
              Material(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome to Moderator Manager",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 200.0),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50), // Set button size
                            ),
                            onPressed: () {
                              if (dropdownValue == "Moderator") {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()),
                                );
                              } else if (dropdownValue == "Admin") {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AdminLogin()
                                  ),
                                );
                              }
                            },
                            child: Text(
                              dropdownValue == "Moderator"
                                  ? "Login"
                                  : "Admin Login",
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50), // Set button size
                            ),
                            onPressed: () {
                              if (dropdownValue == "Moderator") {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register()),
                                );
                              } else if (dropdownValue == "Admin") {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminRegister()),
                                );
                              }
                            },
                            child: Text(
                              dropdownValue == "Moderator"
                                  ? "Register"
                                  : "Admin Register",
                              style: TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
