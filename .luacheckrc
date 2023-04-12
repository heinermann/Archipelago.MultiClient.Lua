return {
  std = "min",
  exclude_files = { "lib/external/" },
  include_files = { "lib", "spec" },
  ignore = {"212"},
  compat = true,
  not_globals = {
    -- Noita restricted
    "loadstring", "require", "gcinfo", "collectgarbage",
    "coroutine", "debug", "io", "os", "package",

    -- Noita compatibility
    "bit", "jit", "do_mod_appends", "dofile_once", "print_error",

    -- Civ V restricted
    "load", "require", "loadfile",

    -- compatibility
    "getfenv", "loadstring", "module", "rawlen", "setfenv", "unpack",
    "bit32", "utf8", "file",

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
