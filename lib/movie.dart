import 'package:hive/hive.dart';
part 'movie.g.dart';

@HiveType(typeId: 1)
class Movie extends HiveObject {
  Movie({required this.name, required this.id, required this.poster, required this.director});

  @HiveField(0)
  String name;

  @HiveField(1)
  int id;

  @HiveField(2)
  String poster;

  @HiveField(3)
  String director;

  @override
  String toString() {
    return '$name: $director';
  }
}