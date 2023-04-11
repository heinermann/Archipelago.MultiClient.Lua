rockspec_format = "3.0"
package = "Archipelago.MultiClient.Lua"
version = "1.0-1"
source = {
   url = "git+ssh://git@github.com/heinermann/Archipelago.MultiClient.Lua.git"
}
description = {
   summary = "A client library written in Lua for use with Archipelago.",
   detailed = "",
   homepage = "https://github.com/heinermann/Archipelago.MultiClient.Lua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}
build = {
   type = "builtin",
   modules = {
      APClient = "lib/APClient.lua"
   }
}
test = {
   type = "busted"
}
