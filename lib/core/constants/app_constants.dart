class AppConstants {
  // App info
  static const String appName = 'TeamCoach';
  static const String appVersion = '1.0.0';
  
  // Appwrite configuration
  static const String appwriteEndpoint = 'https://nyc.cloud.appwrite.io/v1';
  static const String appwriteProjectId = '685f0f73002eb202649e';
  
  // Database and collections
  static const String databaseId = 'teamcoach_db';
  static const String teamsCollection = 'teams';
  static const String playersCollection = 'players';
  static const String gamesCollection = 'games';
  static const String gameLineupsCollection = 'game_lineups';
  static const String playsCollection = 'plays';
  static const String teamSettingsCollection = 'team_settings';
  
  // Default settings
  static const int defaultInningsPerGame = 7;
  static const int defaultRosterSizeLimit = 25;
  
  // Position list
  static const List<String> positions = [
    'P',   // Pitcher
    'C',   // Catcher
    '1B',  // First Base
    '2B',  // Second Base
    '3B',  // Third Base
    'SS',  // Shortstop
    'LF',  // Left Field
    'CF',  // Center Field
    'RF',  // Right Field
    'DH',  // Designated Hitter
  ];
  
  // Position names in Spanish
  static const Map<String, String> positionNames = {
    'P': 'Lanzador',
    'C': 'Receptor',
    '1B': 'Primera Base',
    '2B': 'Segunda Base',
    '3B': 'Tercera Base',
    'SS': 'Parador en Corto',
    'LF': 'Jardinero Izquierdo',
    'CF': 'Jardinero Central',
    'RF': 'Jardinero Derecho',
    'DH': 'Bateador Designado',
  };
} 