import 'package:aws_ai/aws_ai.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker_saver/image_picker_saver.dart' as omg;
import 'package:http/http.dart' as http;
import 'dart:convert';


File sourceImagefile, targetImagefile;
String accessKey="AKIAVETU4ZR4NTDWGSXN";
String secretKey="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";
String region ="us-east-1";

RekognitionHandler rekognition = new RekognitionHandler(accessKey, secretKey, region);



class SimilarityAnalysis extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
    return _SimilarityAnalysis();
  }
}

class _SimilarityAnalysis extends State<SimilarityAnalysis>{


  Future<String> labelsArray;
  List<List<String>> imagesList = [];
  String similarityIndex;



  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }


  Future<String> getSimilarityData(File f1, File f2) async{
    //File f1 = await getImageFileFromAssets(("modi2.jpg"));
   // File f2 = await getImageFileFromAssets(("trump.jpg"));
    String labelsArray = await rekognition.compareFaces(f1,f2);
    return labelsArray;
}

File _image;

  Future getImage() async {

    showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createLoadingDialog());
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 500,maxHeight: 1200);
    setState(() {
      _image=image;
    });
    Navigator.pop(context);

  }

  @override
  void initState() {
    // TODO: implement initState
    loadImagesFromFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 2,
           child: Container(
             width: double.maxFinite,
             margin: EdgeInsets.all(16),
             decoration: BoxDecoration(
             color: Colors.white12,
               border: Border.all(color: Colors.black)
           ),
             child: GestureDetector(
               child:_image!=null?Image.file(_image):Text("Help Finding Missing Soul",textAlign: TextAlign.center,style: TextStyle(fontSize: 21),),
               onTap: () async{
                 await getImage();
                 showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createLoadingDialog());
                 if(_image!=null){
                   print("I am here");
                   for(int i=0;i<imagesList.length-1;i++){
                     print(imagesList[i]);
                     var response = await http.get(imagesList[i][0]);
                     var filePath = await omg.ImagePickerSaver.saveFile(fileData: response.bodyBytes);
                     File f1= File.fromUri(Uri.file(filePath));

                     String temp = await getSimilarityData(_image,f1);
                     Map<String, dynamic> user = jsonDecode(temp);
                     if(user["FaceMatches"]!=null){
                     if(user["FaceMatches"].length>0){
                       setState(() {
                         print(user["FaceMatches"][0]);
                         similarityIndex =
                             user["FaceMatches"][0]["Similarity"].toString();
                         DatabaseReference db = FirebaseDatabase.instance
                             .reference();
                         db.child("MissingPeopleDatabase").child(
                             imagesList[i][1]).update({'missing': false});
                       } );
                       break;
                     }
                   }}
                   Navigator.of(context).pop();
                 }
                 //loadImages(_image, f2);
               },
             ),
           )),
        Expanded(
          flex: 1,
          child: similarityIndex==null?Text("Not Found",style: TextStyle(fontSize: 24),):
              Text("Found with similarity "+similarityIndex.toString(),style: TextStyle(fontSize: 24),)
        )

      ]);
  }


  Future<void> loadImagesFromFirebase() async{

    DatabaseReference db = FirebaseDatabase.instance.reference();
    await db.child('MissingPeopleDatabase').once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var data = snapshot.value;
      for (var key in keys) {
        if(data[key]['missing']){
          String image=data[key]['imagespath'][0];
          setState(() {
            imagesList.add([image,key]);
          });
        }
        }

       });
    print(imagesList);
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

}