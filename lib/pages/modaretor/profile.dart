import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mod_maneger_v3/pages/Previous/land_page.dart';
import 'package:mod_maneger_v3/pages/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _withdrawController = TextEditingController();
  final database db = database();
  String email = "";

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LandPage()),
    );
  }

  void _showWithdrawPopup(num availableBalance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw Balance'),
          content: TextField(
            controller: _withdrawController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _withdrawController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(

              onPressed: () async {
                final enteredAmount = _withdrawController.text;
                if (enteredAmount.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an amount'),
                    ),
                  );
                  return;
                }

                final withdrawAmount = num.tryParse(enteredAmount);
                if (withdrawAmount == null || withdrawAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                if (withdrawAmount > availableBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insufficient balance'),
                    ),
                  );
                  return;
                }

                try {
                  await db.updateData(email, {
                    'Withdraw_amount': withdrawAmount,
                    'Withdraw_request': true,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Withdrawal request of \$$withdrawAmount submitted!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error processing withdrawal: $e'),
                    ),
                  );
                }

                _withdrawController.clear();
                Navigator.pop(context);
              },
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (email.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: db.getonemoddetails(email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No data available"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['Mod_name'];
          final availableBalance = data['Available_balance'];
          final totalCommission = data['Total_commission'];
          final totalWithdraw = data['Total_withdraw'];
          final totalselltk = data['Total_selltk'];
          final totalsell = data['Total_sell'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: $name",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Change Password option tapped.'),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.lock),
                      SizedBox(width: 10),
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 24,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                      "Total unit sells: $totalsell",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                const SizedBox(height: 30),
                Text(
                      "Total sells price: $totalselltk",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                const SizedBox(height: 30),
                Text(
                  "Total Commission: $totalCommission",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),
                Text(
                  "Available Balance: $availableBalance",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Total withdraw: $totalWithdraw",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showWithdrawPopup(availableBalance),
                    child: const Text('Withdraw Balance'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}