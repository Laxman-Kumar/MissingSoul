import 'package:flutter/material.dart';
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

class RegisterMissingPeople extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _RegisterMissingPeople();
  }
}

class _RegisterMissingPeople extends State<RegisterMissingPeople>{

  TextEditingController mMissingnName = TextEditingController();
  TextEditingController mMissingAge = TextEditingController();
  TextEditingController mMissingIdentification = TextEditingController();
  TextEditingController mMissingDescription = TextEditingController();


  String predictionResult = "Search for place";

  Future getImage() async {

    showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createLoadingDialog());
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 500,maxHeight: 1200);
    setState(() {
      _image=image;
    });
    Navigator.pop(context);
    if(_image!=null){
      showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => ShowImageDialog());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
                Text("Missing Person Information",style: TextStyle(fontSize: 21),),
                Padding(padding: EdgeInsets.only(top: 16),),
                TextField(
                  controller:mMissingnName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: mName,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingAge,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: mAge,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingIdentification,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: mPossibleIdentificationNumber,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                TextField(
                  controller:mMissingDescription,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: mDescription,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8),),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        border: Border.all(color: Colors.black26)
                    ),
                    height: 40,
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
                Container(
                  height: 150,
                  margin: EdgeInsets.all(8),
                  child:Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text("Attach Image",textAlign: TextAlign.start,style: TextStyle(fontSize: 21,color: Color(0xFF121757)),),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                      ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Container(
                                child: drawImage(),
                              ),
                              Container(
                                  height: 60,
                                  width: 60,
                                  child:  RaisedButton(
                                    onPressed: () async{
                                      await getImage();
                                    },
                                    child: Text("+",style: TextStyle(fontSize: 24),),
                                  )
                              )
                            ],)
                      )
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16),),
                RaisedButton(
                  onPressed: onUpload,
                  child: Text("Upload Data"),
                )
              ],
            ),
          ),


        ],
      ),

    ));
  }

  Future<String> uploadingImages(File file) async{
    String path;
    showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createLoadingDialog());
    StorageReference storeRef = FirebaseStorage.instance.ref().child("MissingPeopleDataset");
    StorageMetadata metaData = StorageMetadata(contentType: 'image/jpg');
    final StorageUploadTask uploadTask =await storeRef.child(Uuid().v1().toString()).putFile(file, metaData);
    try{
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      if(uploadTask.isCanceled){path = file.path;}
      if(uploadTask.isPaused){print("pauseddddd");
      path = file.path;}
      final String url = (await downloadUrl.ref.getDownloadURL());
      if(uploadTask.isComplete){path= url;print("completed");}
      Navigator.pop(context);
    }
    catch(e){
      print("errrrrror"+e.toString());
      Navigator.pop(context);
    }

    return path;

  }

  Future<void> onUpload() async{

    List<String> imagesPathList = [];
    for(int i=0;i<ImageList.length;i++){
      print(ImageList[i]);
      String pth  = await uploadingImages(File(ImageList[i].path));
      imagesPathList.add(pth);
    }
    print(imagesPathList);

    var uuid = new Uuid();
    DatabaseReference db = FirebaseDatabase.instance.reference();
    db.child("MissingPeopleDatabase").child(uuid.v1()).set({
      'Time':DateTime.now().toString(),
      'name':mMissingnName.text,
      'age':mMissingAge.text,
      'description':mMissingDescription.text,
      'identifcationNumber':mMissingIdentification.text,
      'lastseen':predictionResult,
      'missing':true,
      'registerby':{
        "relation":"Father",
        "Name":"Laxman",
        "IDType":"Pan",
        "ID":"fdfsdfsdfsd",
        "Address":"dsfgsdfsdf"
      },
      'imagespath':imagesPathList
    });
    showDialog(barrierDismissible: false,context: context, builder: (BuildContext context) => createDisplayDialog());
    dispose();
  }

  List<File> ImageList = [];
  List<ImageDetailsClass> ImagePath =[];
  File _image;

  Row drawImage() {
    final childrenRow = <Widget>[];
    for (int i = 0; i < ImagePath.length; i++) {
      childrenRow.add(Container(
        margin: EdgeInsets.only(right: 8),
        constraints: BoxConstraints(
            maxHeight:120,
            maxWidth: 170
        ),
        child: Image.file(ImageList[i]),));
    }
    return Row(
      children: childrenRow,
    );
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

  Dialog createDisplayDialog() {
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
                Text("Missing details uploaded successfully",style: TextStyle(fontSize: 18),),
                Padding(padding: EdgeInsets.only(top: 16),),
                RaisedButton(child: Text("Close"),onPressed: (){Navigator.of(context).pop();},)

              ],
            ))

    );
  }


  Dialog ShowImageDialog(){
    return  Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
        ),
        //this right here
        child: Container(
          margin: EdgeInsets.all(16.0),
          height: 450.0,
          width: 200,
          child: Column(
            children: <Widget>[

              Expanded(
                child: _image==null?Center(child:CircularProgressIndicator()):Image.file(_image),
              ),

              Row(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async{
                      String path;
                      path = _image.path;
                      print(path);
                      setState(() {
                        ImageList.add(_image);
                        ImagePath.add(ImageDetailsClass(path:path));
                      });

                      Navigator.of(context).pop();
                    },
                    child: Text("Add"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                  ),
                  RaisedButton(
                    child: Text("Cancel"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  ),
                ],

              )

            ],
          ),
        )

    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mMissingnName.clear();
   mMissingAge.clear();
   mMissingIdentification.clear();
   mMissingDescription.clear();
   predictionResult="Search for address";
   setState(() {
     ImageList.clear();
     ImagePath.clear();

   });
    super.dispose();
  }
}