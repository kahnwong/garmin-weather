using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;

class GarminWeatherView extends Ui.View {
  // api response
  var _description;
  var _temperature;
  var _rain_start;
  var _rain_stop;
  var _weatherService;

  function initialize() {
    View.initialize();

    _weatherService = new WeatherService(method(:onWeatherDataReceived));

    // Try to load from cache first
    var cachedData = WeatherCache.loadFromCache();
    if (cachedData != null) {
      System.println("Loaded weather data from cache");
      _description = cachedData.get("description") as Lang.String;
      _temperature = cachedData.get("temperature");
      _rain_start = cachedData.get("rain_start");
      _rain_stop = cachedData.get("rain_stop");
    } else {
      System.println("Cache invalid or empty, fetching new data");
      _weatherService.makeWeatherRequest();
    }
  }

  function onLayout(dc) {}

  function onShow() {}

  function onUpdate(dc) {
    View.onUpdate(dc);

    // clear the screen
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.clear();

    // Check if cache is expired and refresh if necessary
    if (_description != null && !WeatherCache.isCacheValid()) {
      System.println("Cache expired, fetching new data...");
      _weatherService.makeWeatherRequest();
    }

    // display content
    if (_description != null) {
      // draw description - multi-line
      var allLines = [];
      var wrapped = wordWrapByWords(_description, 11);
      for (var j = 0; j < wrapped.size(); ++j) {
        allLines.add(wrapped[j]);
      }

      var y = 30;
      for (var row = 1; row <= 3; ++row) {
        var text = row - 1 < allLines.size() ? allLines[row - 1] : "";
        dc.drawText(30, y, Gfx.FONT_XTINY, text, Gfx.TEXT_JUSTIFY_LEFT);
        y += 20;
      }

      // the rest
      dc.drawText(
        30,
        100,
        Gfx.FONT_XTINY,
        "Temp: " + _temperature.toNumber() + "°C",
        Gfx.TEXT_JUSTIFY_LEFT
      );

      dc.drawText(
        30,
        120,
        Gfx.FONT_XTINY,
        "Start: " + formatRainTime(_rain_start),
        Gfx.TEXT_JUSTIFY_LEFT
      );
      dc.drawText(
        30,
        140,
        Gfx.FONT_XTINY,
        "Stop: " + formatRainTime(_rain_stop),
        Gfx.TEXT_JUSTIFY_LEFT
      );
    }
  }

  function onHide() {}

  // --------- weather data callback ---------
  function onWeatherDataReceived(data) {
    _description = data.get("description");
    _temperature = data.get("temperature");
    _rain_start = data.get("rain_start");
    _rain_stop = data.get("rain_stop");

    // Save to persistent storage cache using shared WeatherCache
    WeatherCache.saveToCache(data);

    Ui.requestUpdate();
  }

  function formatRainTime(value) {
    if (value == null) {
      return "-";
    }

    var text = value as Lang.String;
    if (text.equals("now")) {
      return "Now";
    }

    var length = text.length();
    if (length > 0 && text.substring(length - 1, length).equals("h")) {
      return text.substring(0, length - 1) + "H";
    }
    return text;
  }

  // --------- text processing ---------
  function wordWrapByWords(text, maxLen) {
    var words = [];
    var s = text;
    while (s.length() > 0) {
      var chars = s.toCharArray();
      var splitIndex = -1;
      for (var i = 0; i < chars.size(); i++) {
        if (chars[i] == " ".toCharArray()[0]) {
          splitIndex = i;
          break;
        }
      }
      if (splitIndex == -1) {
        words.add(s);
        break;
      } else {
        words.add(s.substring(0, splitIndex));
        s = s.substring(splitIndex + 1, s.length());
      }
    }
    var lines = [];
    var currentLine = "";
    for (var i = 0; i < words.size(); ++i) {
      var word = words[i];
      if (currentLine.length() == 0) {
        currentLine = word;
      } else if (currentLine.length() + 1 + word.length() <= maxLen) {
        currentLine += " " + word;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.length() > 0) {
      lines.add(currentLine);
    }
    return lines;
  }
}
