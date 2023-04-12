-- Functions intended for cross-compatibility
local Compat = {}

-- luacheck: push ignore
Compat.unpack = table.unpack or unpack
-- luacheck: pop

return Compat
