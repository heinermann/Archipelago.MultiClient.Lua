return {
  std = "min",
  exclude_files = { "lib/external/" },
  include_files = { "lib", "spec" },
  ignore = {"212"},
  compat = true,
  not_globals = {
    -- Noita restricted
    "loadfile", "loadstring", "require", "gcinfo", "collectgarbage",
    "coroutine", "debug", "io", "os", "package",

    -- Compat
    "getfenv", "loadstring", "module", "rawlen", "setfenv", "unpack",
    "bit32", "bit", "utf8", "file",

    -- table compat
    "table.maxn", "table.move", "table.pack", "table.unpack",

    -- math compat
    "math.atan2", "math.cosh", "math.frexp", "math.ldexp", "math.log10",
    "math.maxinteger", "math.mininteger", "math.pow", "math.sinh", "math.tanh",
    "math.tointeger", "math.type", "math.ult",

    -- string compat
    "string.pack", "string.packsize", "string.unpack",
  }
}
