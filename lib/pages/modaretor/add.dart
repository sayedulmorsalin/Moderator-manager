import 'package:flutter/material.dart';
import 'package:mod_maneger_v3/pages/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final database db = database(); // Instance of the database service
  String email = "", mod_name="", delivery="Pending";
  int result=0;
  bool admin_appruval= false, isLoading = false;
  String customer_name="",order_id="",product_name="",quantity_product="",total_price="",mod_com="";

  TextEditingController customernamecontroller = TextEditingController();
  TextEditingController orderidcontroller = TextEditingController();
  TextEditingController productnamecontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController totalpricecontroller = TextEditingController();
  TextEditingController modcomcontroller = TextEditingController();

  final _formkey=GlobalKey<FormState>();

  @override
  Future<void> _loadModName() async {
    var data = await db.getonemoddetails(email).first;
    setState(() {
      mod_name = data['Mod_name'] ?? "Default Mod Name";
    });
  }



  @override
  void initState() {
    super.initState();
    _loadEmail();

  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? "";
    });
    await _loadModName();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Order ",
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
          margin: EdgeInsets.only(left: 20.0, top: 30.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Name",
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
                        return 'Please enter customer name';
                      }
                      return null;
                    },
                    controller: customernamecontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Order id",
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
                    controller: orderidcontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Product name",
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
                        return 'Please enter Product name';
                      }
                      return null;
                    },
                    controller: productnamecontroller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Quantity of product",
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
                        return 'Please enter Quantity';
                      }
                      return null;
                    },
                    controller: quantitycontroller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Total price ",
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
                        return 'Please enter Price';
                      }
                      return null;
                    },
                    controller: totalpricecontroller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  "Mod commission",
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
                        return 'Please enter Commission';
                      }
                      return null;
                    },
                    controller: modcomcontroller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 15.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async{
                      isLoading= true;
                      int serial = await db.getserialnumber();
                      result = serial + 1;
                      if(_formkey.currentState!.validate()){
                      Map<String,dynamic> customerinfomap = {
                        "Serial_number": result,
                        "Customer_name": customernamecontroller.text,
                        "Order_id": orderidcontroller.text,
                        "Product_name": productnamecontroller.text,
                        "Quantity_of_product": quantitycontroller.text,
                        "Total_price": totalpricecontroller.text,
                        "Mod_commission": modcomcontroller.text,
                        "Mod_name": mod_name,
                        "Mod_email": email,
                        "Delivery_status": delivery,
                        "Date_time": DateTime.now(),

                      };
                      order_id=orderidcontroller.text;
                      try {
                        await database().addcpdetails(customerinfomap, order_id).then((onValue) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Details uploaded!")),

                          );
                          isLoading=false;
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Home()));
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }finally {
                        isLoading = false;
                      }

                      }


                    },
                    child: isLoading ? CircularProgressIndicator(color: Colors.green):
                    Text(
                      "Upload",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

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
