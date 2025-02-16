import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mod_maneger_v3/pages/modaretor/add.dart';
import 'package:mod_maneger_v3/pages/modaretor/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int result=1;
  String email = "";
  String moderatoremail = "";
  String customer_name = "",
      order_id = "",
      product_name = "",
      quantity_product = "",
      total_price = "",
      mod_com = "",
      status = "";
  String selectedStatus = "Pending";
  final database db = database();

  Stream? cpstream;

  Future<void> getontheload() async {
    if (email.isNotEmpty) {
      setState(() {
        moderatoremail = email;
        cpstream = FirebaseFirestore.instance
            .collection('Cpdetails')
            .where('Mod_email', isEqualTo: email)
            .orderBy('Serial_number', descending: true) // Sorting added here
            .snapshots();
      });
    }
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? ""; // Get email from shared preferences
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEmail().then((_) => getontheload()); // Load email first, then fetch data
  }

  Widget allcpdetails() {
    return StreamBuilder(
        stream: cpstream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            // Display error message
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, Index) {
                    DocumentSnapshot ds = snapshot.data.docs[Index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 30.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Serial number: ",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ds["Serial_number"].toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Text(
                                      "Customer Name: ",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ds["Customer_name"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Order ID: ",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ds["Order_id"],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.copy, color: Colors.blue),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: ds["Order_id"])); // Fix here

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Order ID copied to clipboard'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Product Name: ",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ds["Product_name"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Quantity of product: ",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ds["Quantity_of_product"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Total price: ",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ds["Total_price"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Mod commission: ",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ds["Mod_commission"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Status: ",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ds["Delivery_status"],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(children: [
                                  SizedBox(height: 30.0),
                                  Center(
                                    child: Row(
                                      children: [
                                        SizedBox(height: 30.0),
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 50.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(
                                                    50, 30), // Set button size
                                              ),
                                              onPressed: ds["Delivery_status"] == "Pending"
                                            ? () {{
                                                customernamecontroller.text=ds["Customer_name"];
                                                orderidcontroller.text= ds["Order_id"];
                                                productnamecontroller.text=ds["Product_name"];
                                                quantitycontroller.text=ds["Quantity_of_product"];
                                                totalpricecontroller.text=ds["Total_price"];
                                                modcomcontroller.text=ds["Mod_commission"];
                                                setState(() {
                                                  selectedStatus = ds["Delivery_status"]; // Initialize selectedStatus
                                                });
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) {
                                                    return SingleChildScrollView(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 20.0,
                                                          right: 20.0,
                                                          top: 30.0,
                                                          bottom: MediaQuery.of(
                                                              context)
                                                              .viewInsets
                                                              .bottom +
                                                              20.0,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Text(
                                                              "Customer Name",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20.0,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            Container(
                                                              padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                              decoration:
                                                              getTextFieldDecoration(),
                                                              child: TextField(
                                                                controller: customernamecontroller,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                    InputBorder
                                                                        .none),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                            Text(
                                                              "Order ID",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20.0,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            Container(
                                                              padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                              decoration:
                                                              getTextFieldDecoration(),
                                                              child: TextField(
                                                                controller: orderidcontroller,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                    InputBorder
                                                                        .none),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                            Text(
                                                              "Product Name",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20.0,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            Container(
                                                              padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                              decoration:
                                                              getTextFieldDecoration(),
                                                              child: TextField(
                                                                controller: productnamecontroller,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                    InputBorder
                                                                        .none),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                            Text(
                                                              "Quantity of Product",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20.0,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            Container(
                                                              padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                              decoration:
                                                              getTextFieldDecoration(),
                                                              child: TextField(
                                                                controller: quantitycontroller,
                                                                keyboardType: TextInputType.number,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                    InputBorder
                                                                        .none),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                            Text(
                                                              "Total Price",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20.0,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            Container(
                                                              padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                              decoration:
                                                              getTextFieldDecoration(),
                                                              child: TextField(
                                                                controller: totalpricecontroller,
                                                                keyboardType: TextInputType.number,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                    InputBorder
                                                                        .none),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                            Text(
                                                              "Mod Commission",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20.0,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                            Container(
                                                              padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                              decoration:
                                                              getTextFieldDecoration(),
                                                              child: TextField(
                                                                controller: modcomcontroller,
                                                                keyboardType: TextInputType.number,
                                                                decoration: InputDecoration(
                                                                    border:
                                                                    InputBorder
                                                                        .none),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15.0),
                                                            Center(
                                                              child:
                                                              Row(
                                                                children: [

                                                                  PopupMenuButton<String>(
                                                                    onSelected: (String value) {
                                                                      setState(() {
                                                                        selectedStatus = value;
                                                                      });
                                                                    },
                                                                    itemBuilder: (BuildContext context) {
                                                                      return [
                                                                        PopupMenuItem(
                                                                          value: "Pending",
                                                                          child: Text("Pending",
                                                                              style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold)),
                                                                        ),
                                                                        PopupMenuItem(
                                                                          value: "Delivered",
                                                                          child: Text("Delivered",
                                                                              style:
                                                                              TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
                                                                        ),
                                                                        PopupMenuItem(
                                                                          value: "Canceled",
                                                                          child: Text("Canceled",
                                                                              style: TextStyle(
                                                                                color: Colors.redAccent,
                                                                                fontWeight: FontWeight.bold,
                                                                              )),
                                                                        ),
                                                                      ];
                                                                    },
                                                                    child: ElevatedButton(
                                                                      onPressed: null,
                                                                      child: Text(
                                                                        selectedStatus,
                                                                        style: TextStyle(
                                                                          color: selectedStatus == "Pending"
                                                                              ? Colors.blueAccent
                                                                              : selectedStatus == "Delivered"
                                                                              ? Colors.green
                                                                              : Colors.redAccent,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () async {
                                                                      DocumentSnapshot originalDoc = await FirebaseFirestore.instance
                                                                          .collection('Cpdetails')
                                                                          .doc(orderidcontroller.text)
                                                                          .get();
                                                                      Map<String, dynamic> originalData = originalDoc.data() as Map<String, dynamic>;

                                                                      Map<String, dynamic> updateData = {
                                                                        "Customer_name": customernamecontroller.text,
                                                                        "Order_id": orderidcontroller.text,
                                                                        "Product_name": productnamecontroller.text,
                                                                        "Quantity_of_product": quantitycontroller.text,
                                                                        "Total_price": totalpricecontroller.text,
                                                                        "Mod_commission": modcomcontroller.text,
                                                                        "Delivery_status": selectedStatus,
                                                                      };

                                                                      Map<String, dynamic> nonSensitiveUpdates = {};
                                                                      Map<String, dynamic> sensitiveUpdates = {};

                                                                      ['Customer_name', 'Order_id', 'Product_name'].forEach((key) {
                                                                        if (updateData[key] != originalData[key]) {
                                                                          nonSensitiveUpdates[key] = updateData[key];
                                                                        }
                                                                      });

                                                                      ['Quantity_of_product', 'Total_price', 'Mod_commission', 'Delivery_status'].forEach((key) {
                                                                        if (updateData[key] != originalData[key]) {
                                                                          sensitiveUpdates[key] = updateData[key];
                                                                        }
                                                                      });

                                                                      bool isStatusPending = selectedStatus == 'Pending';

                                                                      if (isStatusPending) {
                                                                        Map<String, dynamic> allUpdates = {...nonSensitiveUpdates, ...sensitiveUpdates};
                                                                        if (allUpdates.isNotEmpty) {
                                                                          await db.updatecpdetails(orderidcontroller.text, allUpdates);
                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                            SnackBar(content: Text("All updates applied directly as status is pending!")),
                                                                          );
                                                                        }
                                                                      } else {
                                                                        if (nonSensitiveUpdates.isNotEmpty) {
                                                                          await db.updatecpdetails(orderidcontroller.text, nonSensitiveUpdates);
                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                            SnackBar(content: Text("Non-sensitive details updated!")),
                                                                          );
                                                                        }

                                                                        if (sensitiveUpdates.isNotEmpty) {
                                                                          // Check for existing pending requests
                                                                          final pendingRequests = await FirebaseFirestore.instance
                                                                              .collection('update_requests')
                                                                              .where('productId', isEqualTo: orderidcontroller.text)
                                                                              .where('moderatorId', isEqualTo: email)
                                                                              .where('status', isEqualTo: 'pending')
                                                                              .get();

                                                                          if (pendingRequests.docs.isNotEmpty) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text("You have a pending request. Please wait for admin approval."),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            await FirebaseFirestore.instance.collection('update_requests').add({
                                                                              'productId': orderidcontroller.text,
                                                                              'customer_name' : customernamecontroller.text,
                                                                              'moderatorId': email,
                                                                              'moderatorName': await db.getUserName(email),
                                                                              'oldData': {
                                                                                'Quantity_of_product': originalData['Quantity_of_product'],
                                                                                'Total_price': originalData['Total_price'],
                                                                                'Mod_commission': originalData['Mod_commission'],
                                                                                'Delivery_status': originalData['Delivery_status'],
                                                                              },
                                                                              'newData': sensitiveUpdates,
                                                                              'status': 'pending',
                                                                              'timestamp': FieldValue.serverTimestamp(),
                                                                            });
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(content: Text("Update request sent for admin approval")),
                                                                            );
                                                                          }
                                                                        }
                                                                      }

                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Update",
                                                                      style: TextStyle(
                                                                        color: Colors.purpleAccent,
                                                                        fontSize: 20.0,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                              }
                                            : null,
                                              child: Text(
                                                "Edit",
                                                style: TextStyle(
                                                  color: Colors.deepPurpleAccent,
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
                                ]),
                                Row(
                                  children: [
                                    Text(
                                      // Convert timestamp to DateTime and format it
                                      DateFormat('dd-MM-yyyy hh:mm a').format(
                                        ds["Date_time"]
                                            .toDate(), // Use .toDate() if it's a Firestore Timestamp
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                      ),
                    );
                  }
                  );

        });
  }

  TextEditingController customernamecontroller = TextEditingController();
  TextEditingController orderidcontroller = TextEditingController();
  TextEditingController productnamecontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController totalpricecontroller = TextEditingController();
  TextEditingController modcomcontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1, // Number of tabs
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Add()));
              },
              child: Icon(Icons.add),
            ),
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dadu ",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Khelaghor",
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    " Product list",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile()));
                  },
                ),
              ],
            ),
            body: Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: allcpdetails()),
              ]),
            )
        )
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
