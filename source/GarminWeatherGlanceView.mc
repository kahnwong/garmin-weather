using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Lang;

class GarminWeatherGlanceView extends WatchUi.GlanceView {
  var _temperature;
  var _rain_start;
  var _rain_stop;
  var _weatherService;

  function initialize() {
    GlanceView.initialize();

    _weatherService = new WeatherService(method(:onWeatherDataReceived));

    // Try to load from shared cache first
    var cachedData = WeatherCache.loadFromCache();
    if (cachedData != null) {
      System.println("GlanceView: Loaded weather data from cache");
      _temperature = cachedData.get("temperature");
      _rain_start = cachedData.get("rain_start");
      _rain_stop = cachedData.get("rain_stop");
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
        formatRainTime(_rain_start) + " / " + formatRainTime(_rain_stop),
        Graphics.TEXT_JUSTIFY_LEFT
      );
    }
  }

  function onHide() as Void {}

  // --------- weather data callback ---------
  function onWeatherDataReceived(data) {
    _temperature = data.get("temperature");
    _rain_start = data.get("rain_start");
    _rain_stop = data.get("rain_stop");

    // Save to shared cache
    WeatherCache.saveToCache(data);

    WatchUi.requestUpdate();
  }

  function formatRainTime(value) {
    if (value == null) {
      return "-";
    }

    var text = value as Lang.String;
    if (text.equals("now")) {
      return "NOW";
    }

    var length = text.length();
    if (length > 0 && text.substring(length - 1, length).equals("h")) {
      return text.substring(0, length - 1) + "H";
    }
    return text;
  }
}
