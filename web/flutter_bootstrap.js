{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Flutter 3.35.2 loads a default Roboto font before app fonts register.
    fontFallbackBaseUrl: new URL('fonts/', document.baseURI).href,
  },
});
