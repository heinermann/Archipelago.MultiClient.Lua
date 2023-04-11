local APClient = dofile("lib.APClient")

describe("APClient", function()

  describe("connection handshake", function()
    describe("when RoomInfo is received", function ()
      it("requests DataPackage for a game we don't know about", function()
        APClient.RegisterGame({})
      end)
    end)
  end)
end)
