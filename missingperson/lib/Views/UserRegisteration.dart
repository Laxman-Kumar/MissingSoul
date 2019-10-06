import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:missingperson/Constans/StringsConstants.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:missingperson/Controllers/Classes.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:missingperson/Views/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

//GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class RegisterPeople extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _RegisterPeople();
  }
}

class _RegisterPeople extends State<RegisterPeople>{

  TextEditingController mMissingnName = TextEditingController();
  TextEditingController mMissingPhone = TextEditingController();
  TextEditingController mMissingIdentification = TextEditingController();
  TextEditingController mMissingPassword = TextEditingController();
  TextEditingController mMissingIdType = TextEditingController();
  TextEditingController mMissingEmail = TextEditingController();


  String predictionResult = "Search for place";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(child:
    Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          //Missing Person information
          Container(
            child: Column(
              children: <Widget>[
                Text("User Registration",style: TextStyle(fontSize: 21),),
                Padding(padding: EdgeInsets.only(top: 16),),
                TextField(
                  controller:mMissingnName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter name",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingEmail,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter email",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingPhone,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter phone number",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingIdType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Identification Type",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingIdentification,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Identification Number",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Create Password",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16),),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        border: Border.all(color: Colors.black26)
                    ),
                    height: 50,
                    width: double.maxFinite,
                    child:GestureDetector(
                        onTap: () async{
                          Prediction p = await PlacesAutocomplete.show(
                            context: context,
                            apiKey: kGoogleApiKey,
                            mode: Mode.overlay, // Mode.fullscreen
                            language: "fr",
                          );
                          setState(() {
                            predictionResult = p.description;
                          });
                        },
                        child: Text(predictionResult,textAlign: TextAlign.left,style: TextStyle(color: Colors.black26),)
                    )
                ),
                Padding(padding: EdgeInsets.only(top: 16),),
                RaisedButton(
                  onPressed: onUpload,
                  child: Text("Register"),
                ),
                Padding(padding: EdgeInsets.only(top: 16),),
                Row(
                  children: <Widget>[
                    Text("Already have an account "),
                    RaisedButton(
                      child: Text("Login"),
                      onPressed: ()async{
                        showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createLoginDialog());
                      },
                    )

                  ],
                )
              ],
            ),
          ),


        ],
      ),

    ));
  }


  Future<void> onUpload() async{

    var uuid = new Uuid();
    DatabaseReference db = FirebaseDatabase.instance.reference();
    db.child("RegisterPeople").child(uuid.v1()).set({
      'Time':DateTime.now().toString(),
      'name':mMissingnName.text,
      'identificationType':mMissingIdType.text,
      'phone':mMissingPhone.text,
      'email':mMissingEmail.text,
      'identifcationNumber':mMissingIdentification.text,
      'address':predictionResult,
      'password':mMissingPassword.text

    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', mMissingEmail.text);
    await prefs.setString('name', mMissingnName.text);


    showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createDisplayDialog("Regsitered successfully"));
    dispose();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Dashboard()));
  }



  Dialog createLoadingDialog() {
    return  Dialog(
        backgroundColor: Colors.white30,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
        ),
        //this right here
        child: Container(
            height: 100.0,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ))

    );
  }

  Dialog createLoginDialog() {
    return  Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
        ),
        //this right here
        child: Container(
          height: 500,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Login",style: TextStyle(fontSize: 21),),
                Padding(padding: EdgeInsets.only(top: 16),),
                TextField(
                  controller:mMissingEmail,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Email",
                  ),
                ),
              Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Password",
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
          RaisedButton(
            child: Text("Login"),
            onPressed: () async{

              bool found = await getDataFromFirebase();
              if(found){
                showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createDisplayDialog("Login Successfull"));
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('email', mMissingEmail.text);
                await prefs.setString('name', mMissingnName.text);
                prefix0.Navigator.of(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Dashboard()));

              }else{
                showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createDisplayDialog("Email and password doesnot match"));
              }
             },
              )
              ],
            ))

    );
  }
  Future<bool> getDataFromFirebase() async{
    bool found=false;
    DatabaseReference db = FirebaseDatabase.instance.reference();
    await db.child('RegisterPeople').once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var data = snapshot.value;
      for (var key in keys) {
       if(mMissingEmail.text==data[key]['email'] && mMissingPassword.text==data[key]['password']){
         found = true;
       }
      }
    });

    return found;

  }

  Dialog createDisplayDialog(String text) {
    return  Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
        ),
        //this right here
        child: Container(
            height: 100.0,
            width: 100,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(text,style: TextStyle(fontSize: 18),),
                Padding(padding: EdgeInsets.only(top: 16),),
                RaisedButton(child: Text("Close"),onPressed: (){Navigator.of(context).pop();},)

              ],
            ))

    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mMissingnName.clear();
    mMissingIdentification.clear();
    predictionResult="Search for address";
    super.dispose();
  }
}