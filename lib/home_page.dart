import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'utility.dart';
import 'movie.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController myTabController;
  final ImagePicker _picker = ImagePicker();
  String imageString = ""; //it will hold the poster of movies
  List<Movie> movies = []; //it will hold all movies from hive box
  bool v = false; //for validation of entries
  int exit = 0; //for double press back to exit
  TextEditingController _directorName = TextEditingController();
  TextEditingController _movieName = TextEditingController();

  @override
  void initState() {
    myTabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        refreshMovies();
      });

    super.initState();
    Box<Movie> box = Boxes
        .getMovies(); //Boxes class is made to fetch the items form the hive boxes
    movies = box.values.toList().cast<Movie>();
  }

  @override
  void dispose() {
    myTabController.dispose();
    Hive.box("movies").close();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit++;
        if (exit == 1) {
          Fluttertoast.showToast(
              msg: "Press Back again",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.white24,
              textColor: Colors.black,
              fontSize: 16.0);
        }
        Timer(Duration(seconds: 2), () {
          exit = 0;
        });
        if (exit > 1) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal,
          title: Text(
            "Movies",
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  "Watched",
                ),
              ),
              Tab(
                child: Text(
                  "Create",
                ),
              ),
            ],
            indicatorColor: Colors.tealAccent[100],
            controller: myTabController,
          ),
        ),
        body: TabBarView(
          children: [
            buildContent(),
            ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    onPressed: () {
                      selectImage(context);
                    },
                    child: imageString != ""
                        ? imageFromBase64String(imageString)
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Colors.amberAccent,
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    child: TextFormField(
                      controller: _movieName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Movie Name",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Enter the name of the movie",
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    child: TextFormField(
                      controller: _directorName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Director Name",
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: "Enter the name of the movie director",
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: GestureDetector(
                        child: Card(
                          color: Colors.tealAccent[200],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            child: Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.0,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          validate();
                          print(v);
                          if (v) {
                            addMovie(_movieName.text, imageString,
                                _directorName.text);
                            imageString = "";
                            FocusScope.of(context).requestFocus(FocusNode());

                            myTabController..animateTo(0);
                            setState(() {});
                            _directorName.clear();
                            _movieName.clear();
                          }
                        }),
                  ),
                ),
              ],
            ),
          ],
          controller: myTabController,
        ),
      ),
    );
  }

  //to refresh the list of movies
  refreshMovies() {
    Box<Movie> box = Boxes.getMovies();
    movies = box.values.toList().cast<Movie>();
    setState(() {});
  }

  // convert a picture into string
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  //to bring back the picture from a string
  Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  //for the cards shown for each movie
  buildContent() {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: movies.length,
        itemBuilder: (BuildContext context, int index) {
          final movie = movies[index];

          return buildMovie(context, movie);
        },
      ),
    );
  }

  //for each movie card
  buildMovie(BuildContext context, Movie movie) {
    return Card(
      color: Colors.amberAccent[100],
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            imageFromBase64String(movie.poster),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 3, 10, 4),
              child: Text(
                movie.name,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
              child: Text(
                movie.director,
                style: TextStyle(fontSize: 15),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _movieName.text = movie.name;
                    _directorName.text = movie.director;
                    imageString = movie.poster;
                    myTabController..animateTo(1);
                    movie.delete();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 17,
                        color: Colors.brown,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("edit")
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text("You Sure?"),
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SimpleDialogOption(
                                    child: Text("Yes, I am."),
                                    onPressed: () {
                                      movie.delete();
                                      refreshMovies();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: Text("Nope!"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        size: 17,
                        color: Colors.brown,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("delete"),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);

    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    Uint8List temp = await file!.readAsBytes();
    String imgString = base64String(temp);
    setState(() {
      imageString = imgString;

    });
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    Uint8List temp = await file!.readAsBytes();
    String imgString = base64String(temp);
    setState(() {
      imageString = imgString;

    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Upload Movie poster"),
            children: <Widget>[
              SimpleDialogOption(
                  child: Text("Photo with Camera"), onPressed: handleTakePhoto),
              SimpleDialogOption(
                  child: Text("Image from Gallery"),
                  onPressed: handleChooseFromGallery),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  addMovie(String name, String img, String director) {
    final movie = Movie(name: name, poster: img, director: director, id: 0);
    final box = Boxes.getMovies();
    box.add(movie);
  }

//for validation of entries
  validate() {
    if (_movieName.text.isEmpty) {
      v = false;
      return showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Center(child: Text("Oops")),
              children: <Widget>[
                Center(child: Text("Need a movie name")),
              ],
            );
          });
    }
    if (_directorName.text.isEmpty) {
      v = false;
      return showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Center(child: Text("Oops")),
              children: <Widget>[
                Center(child: Text("Need a movie director name")),
              ],
            );
          });
    }
    if (imageString.isEmpty) {
      v = false;
      return showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Center(child: Text("Oops!")),
              children: <Widget>[
                Center(child: Text("Need a movie poster image")),
              ],
            );
          });
    } else
      v = true;
  }
}
