class ImageDetailsClass{

  String path;
  ImageDetailsClass({this.path});

  factory ImageDetailsClass.fromJson(Map<String,dynamic> json){
    return new ImageDetailsClass(
        path: json["imagePath"],
    );
  }

  Map<String,dynamic> toJson() => {
    "imagePath":path,
  };
}

class MissingPersonDetails{
  String name,lastSeen,age,description,image;
  bool missing;


  MissingPersonDetails({this.description,this.age,this.image,this.lastSeen,this.name,this.missing});

  factory MissingPersonDetails.fromJson(Map<String,dynamic> json){
    var listData = json["imagespath"] as List;
    List<ImageDetailsClass> ImageList = listData.map((i) => ImageDetailsClass.fromJson(i)).toList();
    return new MissingPersonDetails(
      description: json['description'],
      name: json['name'],
      age: json['age'],
      lastSeen: json['address'],
      image: json['imagespath']
    );
  }

  Map<String,dynamic> toJson() => {

  };

}