import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:missingperson/Controllers/Classes.dart';
class MissingPeopleDirectory extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _MissingPeopleDirectory();
  }
}

class _MissingPeopleDirectory extends State<MissingPeopleDirectory>{




  List<MissingPersonDetails> missingObject = [];

  @override
  void initState() {
    // TODO: implement initState
    getDataFromFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: missingObject.length==0?Center(child: CircularProgressIndicator(),):
      Container(
        width: double.maxFinite,
        child: ListView.builder(shrinkWrap: true,
        itemCount: missingObject.length,
        itemBuilder:(context,int position){
          return missingObject[position].missing?Card(
            elevation: 4,
              child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                child: Image.network(missingObject[position].image,width: 100,),
              ),
              Column(
                  children: <Widget>[
                    Container(
                        child:Text("Name : "+missingObject[position].name,textAlign: TextAlign.left,)
                    ),

                    Container(
                        child:Text("Age : "+missingObject[position].age)
                    ),
                    Container(
                        child:missingObject[position].lastSeen.length>40?Text("Last seen : "+missingObject[position].lastSeen.substring(0,30).toString(),overflow: TextOverflow.ellipsis,):Text("Last seen : "+missingObject[position].lastSeen.toString(),overflow: TextOverflow.ellipsis,)
                    ),
                    Container(
                        child:Text("Description : "+missingObject[position].description,maxLines: 3,)
                    ),

                  ],
                ),

            ],
          )):Container(child:Text(""));
        },
    )));
  }



  Future<void> getDataFromFirebase() async{
    DatabaseReference db = FirebaseDatabase.instance.reference();
    await db.child('MissingPeopleDatabase').once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var data = snapshot.value;
      for (var key in keys) {
        MissingPersonDetails temp = MissingPersonDetails(
            name: data[key]["name"],
            age: data[key]['age'],
            description: data[key]['description'],
            lastSeen: data[key]['lastseen'],
            missing: data[key]['missing'],
            image: data[key]['imagespath'][0]
        );
        setState(() {
          missingObject.add(temp);
        });

      }
    });
    print(missingObject);
  }

}