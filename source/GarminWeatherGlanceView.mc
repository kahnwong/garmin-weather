using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;

class GarminWeatherGlanceView extends WatchUi.GlanceView {
  var _rain_one_hour;
  var _rain_three_hour;
  var _weatherService;

  function initialize() {
    GlanceView.initialize();

    _weatherService = new WeatherService(method(:onWeatherDataReceived));
    _weatherService.makeWeatherRequest();
  }

  function onShow() as Void {}

  function onUpdate(dc as Graphics.Dc) as Void {
    // Set the background color
    dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
    dc.clear();

    // Set text color
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    // System.println(dc.getWidth());
    // System.println(dc.getHeight());

    var w = dc.getWidth();
    var h = dc.getHeight();

    // Content
    if (_rain_one_hour != null) {
      dc.drawText(
        w - w,
        h - h,
        Graphics.FONT_MEDIUM,
        "PRECIPITATION",
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
    _rain_one_hour = data.get("rain_one_hour");
    _rain_three_hour = data.get("rain_three_hour");

    WatchUi.requestUpdate();
  }
}
