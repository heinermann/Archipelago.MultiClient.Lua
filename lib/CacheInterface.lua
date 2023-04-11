local Object = dofile("data/archipelago/lib/classic/classic.lua")

local CacheInterface = Object:extend()

function CacheInterface:new(cache_name)
	self.cache_name = cache_name
	self.cache_id = "AP_CACHE_" .. cache_name
	self.dirty_id = self.cache_id .. "_dirty"
	_G[self.dirty_id] = true
	_G[self.cache_id] = {}
end

function CacheInterface:reset()
	_G[self.cache_id] = {}
	self:write()
end

function CacheInterface:restore()
	_G[self.dirty_id] = false
end

function CacheInterface:write()
	_G[self.dirty_id] = false
end

function CacheInterface:check_dirty()
	if _G[self.dirty_id] then
		self:restore()
	end
end

function CacheInterface:set(key, value)
	self:check_dirty()
	_G[self.cache_id][key] = (value or true)
	self:write()
end

function CacheInterface:get(key, default_value)
	self:check_dirty()

	local result = _G[self.cache_id][key]
	if result == nil and type(key) == "number" then
		result = _G[self.cache_id][tostring(key)]
	end
	return result or default_value
end

function CacheInterface:is_set(key)
	self:check_dirty()
	return _G[self.cache_id][key] ~= nil
end

function CacheInterface:is_empty()
	self:check_dirty()
	return rawequal(next(_G[self.cache_id]), nil)
end

function CacheInterface:reference()
	return _G[self.cache_id]
end

return CacheInterface
