import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sales History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Daily"),
              Tab(text: "Monthly"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyHistory(),
            _buildMonthlyHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_sales')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No daily sales data available"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            DateTime date = DateFormat('yyyy-MM-dd').parse(doc['date']);

            return Card(
              margin: const EdgeInsets.all(8),
              elevation: 3,
              child: ListTile(
                title: Text(DateFormat('dd MMM yyyy').format(date)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Units Sold: ${doc['total_sell']}"),
                    Text("Total Commission: ৳${doc['total_commission']}"),
                  ],
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("৳${doc['total_selltk']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${doc['total_sell']} items"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthlyHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('monthly_sales')
          .orderBy('month', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No monthly sales data available"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            DateTime month = DateFormat('yyyy-MM').parse(doc['month']);

            return Card(
              margin: const EdgeInsets.all(8),
              elevation: 3,
              child: ListTile(
                title: Text(DateFormat('MMMM yyyy').format(month)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Units: ${doc['total_sell']}"),
                    Text("Total Commission: ৳${doc['total_commission']}"),
                  ],
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("৳${doc['total_selltk']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${doc['total_sell']} items"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}