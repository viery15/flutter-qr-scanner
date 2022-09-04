import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner/navigation_bar.dart';
import 'package:flutter_qr_code_scanner/qr_scanner.dart';

class Home extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Wedding of Nia & Viery',
            style: TextStyle(
                fontFamily: 'Varela',
                fontSize: 20.0,
                color: Color(0xFF545D68))),
      ),
      body: Container(
        child: SizedBox.shrink(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => QrScanner()));
        },
        backgroundColor: Color(0xFF66BB6A),
        child: Icon(Icons.qr_code_2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(),
    );
  }
}
