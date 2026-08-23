import '../models/farm.dart';

abstract class FarmRepository {
  Future<Farm> getFarm(String farmId);
}
