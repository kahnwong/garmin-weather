using Toybox.Application as App;
using Toybox.Communications;
using Toybox.System;
using Toybox.WatchUi as Ui;

class WeatherService {
  var _callback;

  function initialize(callback) {
    _callback = callback;
  }

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
    if (data != null && _callback != null) {
      _callback.invoke(data);
    }
  }
}
