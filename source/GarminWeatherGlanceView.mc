using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Lang;

class GarminWeatherGlanceView extends WatchUi.GlanceView {
  var _temperature;
  var _rain_one_hour;
  var _rain_three_hour;
  var _weatherService;

  function initialize() {
    GlanceView.initialize();

    _weatherService = new WeatherService(method(:onWeatherDataReceived));

    // Try to load from shared cache first
    var cachedData = WeatherCache.loadFromCache();
    if (cachedData != null) {
      System.println("GlanceView: Loaded weather data from cache");
      _temperature = cachedData.get("temperature");
      _rain_one_hour = cachedData.get("rain_one_hour");
      _rain_three_hour = cachedData.get("rain_three_hour");
    } else {
      System.println("GlanceView: Cache invalid or empty, fetching new data");
      _weatherService.makeWeatherRequest();
    }
  }

  function onShow() as Void {}

  function onUpdate(dc as Graphics.Dc) as Void {
    // Set the background color
    dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
    dc.clear();

    // Check if cache is expired and refresh if necessary
    if (_temperature != null && !WeatherCache.isCacheValid()) {
      System.println("GlanceView: Cache expired, fetching new data...");
      _weatherService.makeWeatherRequest();
    }

    // Set text color
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    // System.println(dc.getWidth());
    // System.println(dc.getHeight());

    var w = dc.getWidth();
    var h = dc.getHeight();

    // Content
    if (_temperature != null) {
      dc.drawText(
        w - w,
        h - h,
        Graphics.FONT_MEDIUM,
        "TEMP: " + _temperature.toNumber() + "°C",
        Graphics.TEXT_JUSTIFY_LEFT
      );

      dc.drawText(
        w - w,
        h / 2 - 5,
        Graphics.FONT_GLANCE_NUMBER,
        "1H: " +
          _rain_one_hour.toNumber() +
          "% - 3H: " +
          _rain_three_hour.toNumber() +
          "%",
        Graphics.TEXT_JUSTIFY_LEFT
      );
    }
  }

  function onHide() as Void {}

  // --------- weather data callback ---------
  function onWeatherDataReceived(data) {
    _temperature = data.get("temperature");
    _rain_one_hour = data.get("rain_one_hour");
    _rain_three_hour = data.get("rain_three_hour");

    // Save to shared cache
    WeatherCache.saveToCache(data);

    WatchUi.requestUpdate();
  }
}
