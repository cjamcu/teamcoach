import 'package:get_it/get_it.dart';
import 'package:teamcoach/core/services/appwrite_service.dart';
import 'package:teamcoach/features/roster/services/player_service.dart';
import 'package:teamcoach/features/games/services/game_service.dart';
import 'package:teamcoach/features/plays/services/play_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register services
  getIt.registerLazySingleton<AppwriteService>(() => AppwriteService());
  
  // Initialize Appwrite
  await getIt<AppwriteService>().initialize();
  
  // Register feature services
  getIt.registerLazySingleton<PlayerService>(() => PlayerService());
  getIt.registerLazySingleton<GameService>(() => GameService());
  getIt.registerLazySingleton<PlayService>(() => PlayService());
} 