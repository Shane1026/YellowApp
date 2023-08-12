import 'package:hive/hive.dart';
import 'package:yellow_app/movie.dart';

//an utility class to handle the boxes from anywhere
class Boxes {
  static Box<Movie> getMovies()=>
      Hive.box<Movie>("movies");
}