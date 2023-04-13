local APClient = dofile("lib/APClient.lua")

describe("APClient", function()

  describe("connection handshake", function()
    describe("when RoomInfo is received", function ()
      it("requests DataPackage for a game we don't know about", function()
        APClient.RegisterGameInterface({}) -- TODO this is nothing, was just testing the specs
      end)
    end)
  end)
end)
