import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mod_maneger_v3/pages/Previous/land_page.dart';
import 'package:mod_maneger_v3/pages/admin/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final database db = database();

  int totalCommission = 0,
      totalsell = 0,
      totalwithdraw = 0,
      availablebalance = 0,
      totalselltk = 0,
      withdrawamound = 0; // Variable to store the value
  bool withdrawrequest = false;
  String email = "";

  void fetchTotalCommission() async {
    try {
      // Get the latest snapshot from Firestore
      DocumentSnapshot snapshot = await db.getonemoddetails(email).first;

      if (snapshot.exists) {
        setState(() {
          totalCommission = snapshot['Total_commission'];
          totalsell = snapshot['Total_sell'];
          totalselltk = snapshot['Total_selltk'];
          totalwithdraw = snapshot['Total_withdraw'];
          withdrawrequest = snapshot['Withdraw_request'];
          withdrawamound = snapshot['Withdraw_amount'];
        });
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Error  $e");
    }
  }

  String customer_name = "",
      moderator_name = "",
      order_id = "",
      product_name = "",
      quantity_product = "",
      total_price = "",
      mod_com = "",
      status = "";
  int serial = 0;

  String selectedStatus = "Pending";
  Stream? cpstream;
  Stream? modstream;
  Stream? pending;
  Stream? canceled;
  Stream? getbackStream;

  Future<void> getontheload() async {
    try {
      final streams = await Future.wait([
        database().getCpdetails(),
        database().getmoddetails(),
        database().getpending(),
        database().getcancel(),  // Original canceled orders
        database().getGetback(), // Getback data
      ]);
      setState(() {
        cpstream = streams[0];
        modstream = streams[1];
        pending = streams[2];
        canceled = streams[3];
        getbackStream = streams[4]; // New getback stream
      });
    } catch (e) {
      print("Error initializing streams: $e");
    }
  }

  Future<void> getsnumber() async {
    var serialNumber =
        await db.getserialnumber(); // Ensure this gets the MAX serial
    setState(() {
      serial = serialNumber + 1;
      if (serial <= 0) serial = 1; // Handle edge cases
    });
  }

  void initState() {
    super.initState();
    _cleanOldDocuments();
    getontheload();
    getsnumber();
  }

  Future<void> _cleanOldDocuments() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final batch = FirebaseFirestore.instance.batch();

    (await FirebaseFirestore.instance
            .collection('Cpdetails')
            .where('Date_time', isLessThan: cutoff)
            .get())
        .docs
        .forEach((doc) => batch.delete(doc.reference));

    await batch.commit();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Replace '/landing' with your actual landing page route
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LandPage()),
    );
  }

  Widget allcpdetails() {
    return StreamBuilder(
        stream: cpstream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
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
                                    "Moderator name:  ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ds["Mod_name"],
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
                                            onPressed: () {
                                              customernamecontroller.text =
                                                  ds["Customer_name"];
                                              orderidcontroller.text =
                                                  ds["Order_id"];
                                              productnamecontroller.text =
                                                  ds["Product_name"];
                                              quantitycontroller.text =
                                                  ds["Quantity_of_product"];
                                              totalpricecontroller.text =
                                                  ds["Total_price"];
                                              modcomcontroller.text =
                                                  ds["Mod_commission"];
                                              setState(() {
                                                selectedStatus = ds[
                                                    "Delivery_status"]; // Initialize selectedStatus
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
                                                              controller:
                                                                  customernamecontroller,
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
                                                              controller:
                                                                  orderidcontroller,
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
                                                              controller:
                                                                  productnamecontroller,
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
                                                              controller:
                                                                  quantitycontroller,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
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
                                                              controller:
                                                                  totalpricecontroller,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
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
                                                              controller:
                                                                  modcomcontroller,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration: InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: 15.0),
                                                          Center(
                                                            child: Row(
                                                              children: [
                                                                PopupMenuButton<
                                                                    String>(
                                                                  onSelected:
                                                                      (String
                                                                          value) {
                                                                    setState(
                                                                        () {
                                                                      selectedStatus =
                                                                          value;
                                                                    });
                                                                  },
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return [
                                                                      PopupMenuItem(
                                                                        value:
                                                                            "Pending",
                                                                        child: Text(
                                                                            "Pending",
                                                                            style:
                                                                                TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                      PopupMenuItem(
                                                                        value:
                                                                            "Delivered",
                                                                        child: Text(
                                                                            "Delivered",
                                                                            style:
                                                                                TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                      PopupMenuItem(
                                                                        value:
                                                                            "Canceled",
                                                                        child: Text(
                                                                            "Canceled",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.redAccent,
                                                                              fontWeight: FontWeight.bold,
                                                                            )),
                                                                      ),
                                                                    ];
                                                                  },
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        null,
                                                                    child: Text(
                                                                      selectedStatus,
                                                                      style:
                                                                          TextStyle(
                                                                        color: selectedStatus ==
                                                                                "Pending"
                                                                            ? Colors.blueAccent
                                                                            : selectedStatus == "Delivered"
                                                                                ? Colors.green
                                                                                : Colors.redAccent,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Map<String,
                                                                            dynamic>
                                                                        updatecpinfo =
                                                                        {
                                                                      "Customer_name":
                                                                          customernamecontroller
                                                                              .text,
                                                                      "Order_id":
                                                                          orderidcontroller
                                                                              .text,
                                                                      "Product_name":
                                                                          productnamecontroller
                                                                              .text,
                                                                      "Quantity_of_product":
                                                                          quantitycontroller
                                                                              .text,
                                                                      "Total_price":
                                                                          totalpricecontroller
                                                                              .text,
                                                                      "Mod_commission":
                                                                          modcomcontroller
                                                                              .text,
                                                                      "Delivery_status":
                                                                          selectedStatus,
                                                                    };
                                                                    try {
                                                                      database()
                                                                          .updatecpdetails(
                                                                              orderidcontroller.text,
                                                                              updatecpinfo)
                                                                          .then((onValue) {
                                                                        Navigator.pop(
                                                                            context);
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text("Details uploaded!")),
                                                                        );
                                                                      });
                                                                    } catch (e) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text(e.toString())),
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                    "Update",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .purpleAccent,
                                                                        fontSize:
                                                                            20.0,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
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
                  })
              : Container();
        });
  }

  Widget allmoddetails() {
    return StreamBuilder(
        stream: modstream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, Index) {
                    DocumentSnapshot ds = snapshot.data.docs[Index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 30.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Modaretor name: ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ds["Mod_name"],
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
                                    "Total sell unit : ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ds["Total_sell"].toString(),
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
                                    "Total sells price  : ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ds["Total_selltk"].toString(),
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
                                    "Total commission: ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ds["Total_commission"].toString(),
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
                                    "Total Withdraw: ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ds["Total_withdraw"].toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Container();
        });
  }

  Widget withdraw() {
    return StreamBuilder(
      stream: modstream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        // Filter documents where Withdraw_request is true
        final filteredDocs = snapshot.data.docs
            .where((doc) => doc['Withdraw_request'] == true)
            .toList();

        return filteredDocs.isEmpty
            ? Center(child: Text("No withdrawal requests pending"))
            : ListView.builder(
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = filteredDocs[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 30.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Moderator name: ",
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ds["Mod_name"],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Total commission: ",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ds["Total_commission"].toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Available balance: ",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ds["Available_balance"].toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Withdraw Request amount: ",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ds["Withdraw_amount"].toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              children: [
                                Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 30, right: 30.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(70, 50),
                                      ),
                                      onPressed: () {
                                        // Use the moderator's email from the current document
                                        String modEmail = ds["Mod_email"];
                                        int withdrawAmount = ds["Withdraw_amount"];

                                        // Update total withdraw and available balance
                                        db.updateData(modEmail, {
                                          'Total_withdraw':
                                              FieldValue.increment(
                                                  withdrawAmount),
                                          'Available_balance':
                                              FieldValue.increment(
                                                  -withdrawAmount),
                                          'Withdraw_request': false,
                                          'Withdraw_amount': 0,
                                        });
                                      },
                                      child: Text(
                                        "Pay",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(70, 50),
                                      ),
                                      onPressed: () {
                                        // Cancel withdrawal request
                                        db.updateData(ds["Mod_email"], {
                                          'Withdraw_request': false,
                                          'Withdraw_amount': 0,
                                        });
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.purple,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }

  Widget updateRequestDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('update_requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No update requests found'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Timestamp timestamp = data['timestamp'];

            // Create maps for new and old data
            Map<String, dynamic> newData =
                (data['newData'] as Map<String, dynamic>?) ?? {};
            Map<String, dynamic> oldData =
                (data['oldData'] as Map<String, dynamic>?) ?? {};

// Merge oldData with newData (keep all oldData, update mutual keys)
            Map<String, dynamic> mergedData =
                Map.from(oldData); // Start with oldData
            newData.forEach((key, value) {
              if (mergedData.containsKey(key)) {
                // Only update existing keys
                mergedData[key] = value;
              }
            });

// Now use mergedData to access values
            String modcommission =
                mergedData["Mod_commission"]?.toString() ?? "";
            String totalprice = mergedData["Total_price"]?.toString() ?? "";
            String quantitys =
                mergedData["Quantity_of_product"]?.toString() ?? "";
            String modemail = data["moderatorId"]?.toString() ?? "";

            return Card(
              margin: EdgeInsets.all(10.0),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Moderator',
                        '${data['moderatorName']} (${data['moderatorId']})'),
                    Row(
                      children: [
                        Text(
                          "Order ID: ",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4), // Add spacing
                        Text(
                          data["productId"] ?? '', // Prevent null error
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4), // Add spacing
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: data["productId"] ?? ''));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order ID copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('New Data:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ...newData.entries
                        .map((entry) => _buildDataRow(entry.key, entry.value)),
                    SizedBox(height: 10),
                    Text('Old Data:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ...oldData.entries
                        .map((entry) => _buildDataRow(entry.key, entry.value)),
                    _buildInfoRow(
                      'Date',
                      DateFormat('d MMMM y \' at \' hh:mm:ss a')
                          .format(timestamp.toDate()),
                    ),
                    Center(
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                // 1. Get references to relevant documents
                                final productRef = FirebaseFirestore.instance
                                    .collection('Cpdetails')
                                    .doc(data['productId']);

                                final requestRef = FirebaseFirestore.instance
                                    .collection('update_requests')
                                    .doc(document.id);


                                // --- NEW CODE START ---
                                // Calculate differences for getback
                                Map<String, dynamic> getbackData = {};

                                // Helper function to parse dynamic values to num
                                num _parseDynamicToNum(dynamic value) {
                                  if (value == null) return 0;
                                  if (value is num) return value;
                                  if (value is String) return num.tryParse(value) ?? 0;
                                  return 0;
                                }

                                // Check Total_price change
                                if (newData.containsKey('Total_price')) {
                                  num oldTotal = _parseDynamicToNum(oldData['Total_price']);
                                  num newTotal = _parseDynamicToNum(newData['Total_price']);
                                  if (newTotal < oldTotal) {
                                    getbackData['total_price_diff'] = oldTotal - newTotal;
                                  }
                                }

                                // Check Quantity_of_product change
                                if (newData.containsKey('Quantity_of_product')) {
                                  num oldQty = _parseDynamicToNum(oldData['Quantity_of_product']);
                                  num newQty = _parseDynamicToNum(newData['Quantity_of_product']);
                                  if (newQty < oldQty) {
                                    getbackData['quantity_diff'] = oldQty - newQty;
                                  }
                                }

                                // Save to getback collection if there are changes
                                if (getbackData.isNotEmpty) {
                                  getbackData['productId'] = data['productId'];
                                  getbackData['customer_name'] = data['customer_name'];
                                  getbackData['moderatorName'] = data['moderatorName'];
                                  getbackData['moderatorId'] = data['moderatorId'];
                                  getbackData['timestamp'] = FieldValue.serverTimestamp();
                                  await FirebaseFirestore.instance.collection('getback').add(getbackData);
                                }

                                // 2. Update the target document with newData
                                await productRef.update(newData);

                                // 3. Update the request status to 'approved'
                                await requestRef.update({'status': 'approved'});

                                // 4. Update moderator totals
                                final getmod = FirebaseFirestore.instance
                                    .collection("moderatordetails")
                                    .doc(modemail);

                                DocumentSnapshot documentSnapshot =
                                    await getmod.get();

                                if (documentSnapshot.exists) {
                                  Map<String, dynamic> data = documentSnapshot
                                      .data() as Map<String, dynamic>;

                                  int quantity = data['Total_sell'] ?? 0;
                                  int sell_price = data['Total_selltk'] ?? 0;
                                  int available = data['Available_balance'] ?? 0;
                                  int commission =
                                      data['Total_commission'] ?? 0;

                                  int quantityAdd =
                                      int.tryParse(quantitys) ?? 0;
                                  int sellAdd = int.tryParse(totalprice) ?? 0;
                                  int comAdd = int.tryParse(modcommission) ?? 0;

                                  await getmod.update({
                                    'Total_sell': quantityAdd + quantity,
                                    'Total_selltk': sellAdd + sell_price,
                                    'Total_commission': comAdd + commission,
                                    'Available_balance': available + comAdd,
                                  });

                                  // 5. Get the updated product document with Date_time
                                  DocumentSnapshot productSnapshot =
                                      await productRef.get();
                                  Timestamp dateTimestamp =
                                      productSnapshot['Date_time'];
                                  DateTime saleDate = dateTimestamp.toDate();

                                  // 6. Format dates for Firestore keys
                                  String dailyKey =
                                      DateFormat('yyyy-MM-dd').format(saleDate);
                                  String monthlyKey =
                                      DateFormat('yyyy-MM').format(saleDate);

                                  // 7. Update daily sales
                                  final dailyRef = FirebaseFirestore.instance
                                      .collection('daily_sales')
                                      .doc(dailyKey);

                                  await FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    DocumentSnapshot dailySnapshot =
                                        await transaction.get(dailyRef);
                                    if (dailySnapshot.exists) {
                                      transaction.update(dailyRef, {
                                        'total_sell':
                                            FieldValue.increment(quantityAdd),
                                        'total_selltk':
                                            FieldValue.increment(sellAdd),
                                        'total_commission':
                                            FieldValue.increment(comAdd),
                                      });
                                    } else {
                                      transaction.set(dailyRef, {
                                        'total_sell': quantityAdd,
                                        'total_selltk': sellAdd,
                                        'total_commission': comAdd,
                                        'date': dailyKey,
                                      });
                                    }
                                  });

                                  // 8. Update monthly sales
                                  final monthlyRef = FirebaseFirestore.instance
                                      .collection('monthly_sales')
                                      .doc(monthlyKey);

                                  await FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    DocumentSnapshot monthlySnapshot =
                                        await transaction.get(monthlyRef);
                                    if (monthlySnapshot.exists) {
                                      transaction.update(monthlyRef, {
                                        'total_sell':
                                            FieldValue.increment(quantityAdd),
                                        'total_selltk':
                                            FieldValue.increment(sellAdd),
                                        'total_commission':
                                            FieldValue.increment(comAdd),
                                      });
                                    } else {
                                      transaction.set(monthlyRef, {
                                        'total_sell': quantityAdd,
                                        'total_selltk': sellAdd,
                                        'total_commission': comAdd,
                                        'month': monthlyKey,
                                      });
                                    }
                                  });

                                  // 9. Delete daily records older than 30 days
                                  final DateTime thresholdDate = DateTime.now()
                                      .subtract(Duration(days: 30));
                                  final String thresholdStr =
                                      DateFormat('yyyy-MM-dd')
                                          .format(thresholdDate);

                                  final QuerySnapshot oldDailyDocs =
                                      await FirebaseFirestore.instance
                                          .collection('daily_sales')
                                          .where('date',
                                              isLessThan: thresholdStr)
                                          .get();

                                  if (oldDailyDocs.docs.isNotEmpty) {
                                    WriteBatch batch =
                                        FirebaseFirestore.instance.batch();
                                    for (var doc in oldDailyDocs.docs) {
                                      batch.delete(doc.reference);
                                    }
                                    await batch.commit();
                                    print(
                                        'Deleted ${oldDailyDocs.docs.length} old daily records');
                                  }

                                  print("Updated Successfully!");
                                } else {
                                  print("No such document exists");
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error approving update: $e')),
                                );
                              }

                              try {
                                final requestRef = FirebaseFirestore.instance
                                    .collection('update_requests')
                                    .doc(document.id);
                                await requestRef.delete();
                                print("Document deleted successfully");
                              } catch (e) {
                                print("Error deleting document: $e");
                              }
                            },
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                color: Colors.indigoAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final requestRef = FirebaseFirestore.instance
                                  .collection('update_requests')
                                  .doc(document.id);
                              try {
                                await requestRef
                                    .delete(); // Delete the document from Firestore
                                print("Document deleted successfully");
                              } catch (e) {
                                print("Error deleting document: $e");
                              }
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child:
                Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDataRow(String key, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$key:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }


  Widget cancel() {
    return StreamBuilder(
      stream: canceled,
      builder: (context, AsyncSnapshot snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        // Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Check if data exists and is not empty
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text("No canceled orders found"));
        }

        // Build list if data exists
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
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
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                            "Moderator name:  ",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ds["Mod_name"],
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

                      // ... (keep all existing UI elements the same) ...

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Show confirmation dialog
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to mark this as received and delete the record?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                try {
                                  // Delete the document from Firestore
                                  await database().deleteCpDetails(ds["Order_id"]);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Order marked as received and deleted!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error deleting order: $e'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Received",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      // ... (rest of the existing UI elements) ...
                    ],
                  ),
                ),
              ),
            );

            // ... rest of your list item code remains the same ...
          },
        );
      },
    );
  }



  Widget getback() {
    return StreamBuilder(
        stream: getbackStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, Index) {
                DocumentSnapshot ds = snapshot.data.docs[Index];
                return Container(
                  margin: EdgeInsets.only(bottom: 30.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Moderator name: ",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ds["moderatorName"],
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
                                "Customer name : ",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ds["customer_name"],
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
                                ds["productId"],
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
                                      text: ds["productId"])); // Fix here

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
                                "Product Price : ",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ds["total_price_diff"].toString(),
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
                                "Quantity of product : ",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ds["quantity_diff"].toString(),
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
                                // Convert timestamp to DateTime and format it
                                DateFormat('dd-MM-yyyy hh:mm a').format(
                                  ds["timestamp"]
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_circle, color: Colors.green), // Green checkmark
                                onPressed: () async {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Receival'),
                                      content: Text('Mark this item as received and delete record?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text('Received',
                                              style: TextStyle(color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmDelete == true) {
                                    try {
                                      // DELETE OPERATION (same as before)
                                      await FirebaseFirestore.instance
                                          .collection('getback')
                                          .doc(ds.id)
                                          .delete();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Item received and removed')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              })
              : Container();
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
      length: 6, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            isScrollable: true, // Makes the TabBar scrollable
            tabs: [
              Tab(icon: Icon(Icons.home),text: "All product",),
              Tab(icon: Icon(Icons.people),text: "All moderator",),
              Tab(icon: Icon(Icons.attach_money),text: "Withdraw",),
              Tab(icon: Icon(Icons.pending_actions), text: "Pending",),
              Tab(icon: Icon(Icons.cancel), text: "Canceled"),
              Tab(icon: Icon(Icons.repeat), text: "Parcel"), // New tab
            ],
          ),

          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Dadu ",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Khelaghor",
                style: TextStyle(
                  color: Colors.indigo,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " Admin panel",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => History()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutConfirmation,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Home Tab
            Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: allcpdetails()),
              ]),
            ),

            // People Tab
            Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: allmoddetails()),
              ]),
            ),

            // Pending Actions Tab

            // Withdraw Request Tab
            Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: withdraw()),
              ]),
            ),

            //update request

            Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: updateRequestDetails()),
              ]),
            ),

            // canceled product

            Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: cancel()),
              ]),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 30.0, bottom: 30.0),
              child: Column(children: [
                Expanded(child: getback()),
              ]),
            ),
          ],
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
