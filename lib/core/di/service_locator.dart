import 'package:all_fold/data/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register Dio as a Singleton
  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);

  // Register ApiService as a Lazy Singleton
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
}
