import 'package:jeevan/domain/models/rover.dart';

abstract class RoverRepository {
  Future<Rover> getRover();
}
