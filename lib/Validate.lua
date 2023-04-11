local Validate = {}

function Validate.any(v)
  if v == nil then
    error("Invalid argument. Value expected.", 2)
  end
end

function Validate.tbl(v)
	if type(v) ~= "table" then
		error("Invalid argument. Table expected.", 2)
	end
end

function Validate.str(v)
	if type(v) ~= "string" then
		error("Invalid argument. String expected.", 2)
	end
end

function Validate.num(v)
	if type(v) ~= "number" then
		error("Invalid argument. Number expected.", 2)
	end
end

function Validate.int(v)
	if type(v) ~= "number" or math.floor(v) ~= v then
		error("Invalid argument. Integer expected.", 2)
	end
end

return Validate
