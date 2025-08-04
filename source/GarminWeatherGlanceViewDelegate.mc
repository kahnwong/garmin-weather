using Toybox.WatchUi;
using Toybox.Lang;

class GarminWeatherGlanceViewDelegate extends WatchUi.GlanceViewDelegate {
  function initialize() {
    GlanceViewDelegate.initialize();
  }

  // Handle select button press (opens the main app)
  function onSelect() as Boolean {
    WatchUi.pushView(new GarminWeatherView(), null, WatchUi.SLIDE_IMMEDIATE);
    return true;
  }
}
