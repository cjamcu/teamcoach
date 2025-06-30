import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';

class AppwriteService {
  static const String _endpoint = 'https://nyc.cloud.appwrite.io/v1';
  static const String _projectId = '685f0f73002eb202649e'; 
  
  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final Teams teams;
  late final Realtime realtime;
  
  // Database IDs
  static const String databaseId = 'teamcoach_db';
  
  // Collection IDs
  static const String teamsCollection = 'teams';
  static const String playersCollection = 'players';
  static const String gamesCollection = 'games';
  static const String gameLineupsCollection = 'game_lineups';
  static const String playsCollection = 'plays';
  static const String teamSettingsCollection = 'team_settings';
  
  AppwriteService() {
    client = Client()
      .setEndpoint(_endpoint)
      .setProject(_projectId)
      .setSelfSigned(); // Remove in production
    
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    teams = Teams(client);
    realtime = Realtime(client);
  }
  
  Future<void> initialize() async {
    try {
      // Configure offline mode
      // According to Appwrite docs, offline mode is automatically handled
      // The SDK will queue operations when offline and sync when online
      
      // Check if user is already logged in
      await account.get();
    } catch (e) {
      // User is not logged in
      print('User not logged in: $e');
    }
  }
  
  // Auth methods
  Future<void> login(String email, String password) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<void> register(String email, String password, String name) async {
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      
      await login(email, password);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
  
  // Singleton pattern with GetIt
  static void registerService() {
    GetIt.I.registerLazySingleton<AppwriteService>(() => AppwriteService());
  }
  
  static AppwriteService get instance => GetIt.I<AppwriteService>();
} 