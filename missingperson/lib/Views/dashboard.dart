import 'package:flutter/material.dart';
import 'package:missingperson/Views/RegisterMissingPerson.dart';
import 'package:missingperson/Views/SimilarityAnalysis.dart';
import 'package:missingperson/Views/missingPeopleDirectory.dart';
import 'package:missingperson/Views/UserRegisteration.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard>{

  int _currentIndex = 1;
  List<Widget> _children =[];
  final List<Widget> _children1 = [
    MissingPeopleDirectory(),
    SimilarityAnalysis(),
    RegisterPeople()
  ];
  final List<Widget> _children2 = [
    MissingPeopleDirectory(),
    SimilarityAnalysis(),
    RegisterMissingPeople(),
    //RegisterPeople()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });}

    @override
  void initState() {
    // TODO: implement initState
      setState(() {
        _children=_children2;
      });
      checkUser();
    super.initState();
  }

  Future<void> checkUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email =  prefs.getString('email');
    if(email==null){
      setState(() {
        _children=_children1;
      });
    }

  }
@override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(title: Text("Missing Soul"),),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.collections),
            title: new Text('Missing People'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.help),
            title: new Text('Help Missing Souls'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.language),
              title: Text('Register Missing')
          )
        ],
      ),

    );
  }

}