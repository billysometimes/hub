part of lug;

class Config {
  static final String LUG_OPEN_SYMBOL = "<%";
  static final String LUG_CLOSE_SYMBOL = "%>";

  static final options = {
    "cache"     : true,                 //whether or not hub should cache files
    "cachePath" : "cache/"              //relative path the cache uses
  };
}