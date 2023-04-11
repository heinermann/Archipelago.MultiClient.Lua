local ConnectionInterface = {}

function ConnectionInterface:send(msg)
end

function ConnectionInterface:error_msg()
  return ""
end

function ConnectionInterface:last_message()
  return nil
end

function ConnectionInterface:poll()
  return false
end

function ConnectionInterface:status()
  return "open"
end

return ConnectionInterface
