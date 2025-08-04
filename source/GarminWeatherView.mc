using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi as Ui;

class GarminWeatherView extends Ui.View {
  // api response
  var _description;
  var _temperature;
  var _rain_one_hour;
  var _rain_three_hour;

  function initialize() {
    View.initialize();

    makeWeatherRequest();
  }

  function onLayout(dc) {}

  function onShow() {}

  function onUpdate(dc) {
    View.onUpdate(dc);

    // clear the screen
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.clear();

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
        "Temp: " + _temperature.toNumber() + " C",
        Gfx.TEXT_JUSTIFY_LEFT
      );

      dc.drawText(
        30,
        120,
        Gfx.FONT_XTINY,
        "1 HR: " + _rain_one_hour.toNumber() + "%",
        Gfx.TEXT_JUSTIFY_LEFT
      );
      dc.drawText(
        30,
        140,
        Gfx.FONT_XTINY,
        "3 HR: " + _rain_three_hour.toNumber() + "%",
        Gfx.TEXT_JUSTIFY_LEFT
      );
    }
  }

  function onHide() {}

  // --------- api request ---------
  function makeWeatherRequest() {
    var apiEndpoint = App.Properties.getValue("apiEndpoint");
    var apiKey = App.Properties.getValue("apiKey");
    System.println(apiEndpoint);
    // System.println(apiKey);

    var params = null;
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => { "X-API-Key" => apiKey },
    };

    System.println("Fetching weather...");
    Communications.makeWebRequest(
      apiEndpoint,
      params,
      options,
      method(:onWeatherReceive)
    );
  }
  function onWeatherReceive(responseCode, data) {
    System.println("Fetching weather: callback ...");
    if (data != null) {
      _description = data.get("description");
      _temperature = data.get("temperature");
      _rain_one_hour = data.get("rain_one_hour");
      _rain_three_hour = data.get("rain_three_hour");

      Ui.requestUpdate();
    }
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
