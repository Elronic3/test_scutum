import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scutum/data/repo/task_repo.dart';
import 'package:scutum/data/repo/weather_repo.dart';
import 'package:scutum/core/presentation/home_screen.dart';
import 'package:scutum/logic/task_manager.dart';
import 'package:scutum/logic/weather_manager.dart';


void main() async {
  // Initializing Flutter Engine
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final taskRepo = TaskRepo(prefs);
    final weatherRepo = WeatherRepo();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TaskBloc(taskRepo)),
        BlocProvider(create: (context) => WeatherBloc(weatherRepo)),
      ], 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task & Weather App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}
