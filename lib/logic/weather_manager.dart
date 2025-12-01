import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scutum/data/models/weather_model.dart';
import 'package:scutum/data/repo/weather_repo.dart';

/// - Events -
// Base class for events (actions)
abstract class WeatherEvent {}

// Event to trigger loading weather
class LoadWeather extends WeatherEvent {
  final String city;
  LoadWeather(this.city);
}

/// - States -
// Base class for states (data)
abstract class WeatherState {}

// Initial state
class WeatherInitial extends WeatherState {}

// State Loading
class WeatherLoading extends WeatherState {}

// State when loaded
class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  WeatherLoaded(this.weather);
}

// State with error
class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

/// - BLoC -
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepo repo;

  WeatherBloc(this.repo) : super(WeatherInitial()) {
    // Event handler
    on<LoadWeather>((event, emit) async {
      // Loading state
      emit(WeatherLoading());
      try {
        // Getting data from repo
        final weather = await repo.fetchWeather(event.city);
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    });
  }
}
