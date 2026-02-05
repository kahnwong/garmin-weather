using Toybox.Application as App;
using Toybox.Lang;
using Toybox.Time;

class WeatherCache {
  // Check if cached data is still valid (less than 1 hour old)
  static function isCacheValid() as Lang.Boolean {
    var timestamp = App.Storage.getValue("cacheTimestamp");
    if (timestamp == null) {
      return false;
    }
    var now = Time.now();
    var elapsed = now.value() - timestamp;
    // Cache is valid for 1 hour (3600 seconds)
    return elapsed < 3600;
  }

  // Load weather data from cache
  static function loadFromCache() as Lang.Dictionary? {
    if (!isCacheValid()) {
      return null;
    }

    var weatherData = App.Storage.getValue("weatherData");
    if (weatherData == null || !(weatherData instanceof Lang.Dictionary)) {
      return null;
    }

    return weatherData;
  }

  // Save weather data to cache
  static function saveToCache(data as Lang.Dictionary) as Void {
    App.Storage.setValue("weatherData", data);
    App.Storage.setValue("cacheTimestamp", Time.now().value());
  }
}
