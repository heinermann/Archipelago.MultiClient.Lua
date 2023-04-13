describe("APClient.RECV", function()
  local match = require("luassert.match")

  local APClient = nil
  local ConnInterface = nil

  local function self_called_with(fn, arg)
    assert.spy(fn).was_called_with(match.is_ref(ConnInterface), arg)
  end

  before_each(function ()
    APClient = mock(dofile("lib/APClient.lua"))
  end)

  describe("RoomInfo", function ()
    -- TODO
  end)

  describe("ConnectionRefused", function ()
    -- TODO
  end)

  describe("Connected", function ()
    -- TODO
  end)

  describe("ReceivedItems", function ()
    -- TODO
  end)

  describe("LocationInfo", function ()
    -- TODO
  end)

  describe("RoomUpdate", function ()
    -- TODO
  end)

  describe("PrintJSON", function ()
    -- TODO
  end)

  describe("DataPackage", function ()
    -- TODO
  end)

  describe("Bounced", function ()
    -- TODO
  end)

  describe("InvalidPacket", function ()
    -- TODO
  end)

  describe("Retrieved", function ()
    -- TODO
  end)

  describe("SetReply", function ()
    -- TODO
  end)
end)
