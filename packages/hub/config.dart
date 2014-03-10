part of hub;

class Config {
  static final String HUB_OPEN_SYMBOL = "<%";
  static final String HUB_CLOSE_SYMBOL = "%>";

  static final options = {
    "cache"     : true,                 //whether or not hub should cache files
    "cachePath" : "cache/"              //relative path the cache uses
  };
}