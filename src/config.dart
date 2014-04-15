part of lug;

class _Config {

  static final options = {
    "cache"     : true,                 //whether or not hub should cache files
    "cachePath" : "cache/",             //relative path the cache uses
    "LUG_OPEN_SYMBOL" : "<%",           //default open token for lug tags
    "LUG_CLOSE_SYMBOL": "%>",           //default close symbol for lug tags
    "LUG_INCLUDE": "include"            //keyword for inlcude
  };
}