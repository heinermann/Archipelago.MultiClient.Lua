describe("APClient.SEND", function()
  local match = require("luassert.match")

  local APClient = nil
  local ConnInterface = nil

  local function self_called_with(fn, arg)
    assert.spy(fn).was_called_with(match.is_ref(ConnInterface), arg)
  end

  before_each(function ()
    APClient = dofile("lib/APClient.lua")

    local conn = dofile("lib/ConnectionInterface.lua")
    ConnInterface = mock(conn)
    APClient.RegisterConnectionInterface(ConnInterface)
  end)

  describe("Connect", function()
    it("sends an uninitialized packet", function()
      APClient.SEND.Connect()
      self_called_with(ConnInterface.send, '[{"cmd":"Connect","game":"","items_handling":7,"name":"","password":"","tags":["AP"],"uuid":"_","version":{"build":0,"class":"Version","major":0,"minor":4}}]')
    end)

    it("sends an initialized packet", function()
      APClient.RegisterGameInterface({
        game = "Noita",
        items_handling = 4
      })

      APClient.SetConnectionInfo("Hein", "Cats", {"AP", "DeathLink"})

      APClient.SEND.Connect()
      self_called_with(ConnInterface.send, '[{"cmd":"Connect","game":"Noita","items_handling":4,"name":"Hein","password":"Cats","tags":["AP","DeathLink"],"uuid":"Noita_Hein","version":{"build":0,"class":"Version","major":0,"minor":4}}]')
    end)

    it("modifies the connection state to connecting", function ()
      spy.on(APClient, "SetConnectionState")
      APClient.SEND.Connect()
      assert.spy(APClient.SetConnectionState).was_called_with(APClient.STATE.CONNECTING)
    end)
  end)

  describe("ConnectUpdate", function()
    describe("sends a packet if", function ()
      it("updates item_handling flags", function ()
        APClient.SEND.ConnectUpdate({items_handling = 7})
        self_called_with(ConnInterface.send, '[{"cmd":"ConnectUpdate","items_handling":7}]')
      end)

      it("updates tags", function ()
        APClient.SEND.ConnectUpdate({tags = {"DeathLink"}})
        self_called_with(ConnInterface.send, '[{"cmd":"ConnectUpdate","tags":["DeathLink"]}]')
      end)

      it("updates both item_handling and tags", function ()
        APClient.SEND.ConnectUpdate({item_handling = 4, tags = {"DeathLink"}})
        self_called_with(ConnInterface.send, '[{"cmd":"ConnectUpdate","item_handling":4,"tags":["DeathLink"]}]')
      end)
    end)
  end)

  describe("Sync", function()
    it("sends a packet", function()
      APClient.SEND.Sync()
      self_called_with(ConnInterface.send, '[{"cmd":"Sync"}]')
    end)
  end)

  describe("LocationChecks", function()
    describe("fails if", function ()
      it("has no argument", function ()
        assert.has_errors(function() APClient.SEND.LocationChecks() end)
      end)
    end)

    describe("gets ignored when", function ()
      it("sends an empty table", function ()
        APClient.SEND.LocationChecks({})
        assert.spy(ConnInterface.send).was_not_called()
      end)
    end)

    describe("sends a packet if", function ()
      it("has one id", function ()
        APClient.SEND.LocationChecks({11000})
        self_called_with(ConnInterface.send, '[{"cmd":"LocationChecks","locations":[11000]}]')
      end)

      it("has a few ids", function ()
        APClient.SEND.LocationChecks({11000, 11001, 11002})
        self_called_with(ConnInterface.send, '[{"cmd":"LocationChecks","locations":[11000,11001,11002]}]')
      end)

      it("has duplicate ids", function ()
        APClient.SEND.LocationChecks({11000, 11000, 11000})
        self_called_with(ConnInterface.send, '[{"cmd":"LocationChecks","locations":[11000,11000,11000]}]')
      end)
    end)
  end)

  describe("LocationScouts", function()
    describe("fails if", function ()
      it("has no argument", function ()
        assert.has_errors(function() APClient.SEND.LocationScouts() end)
      end)
    end)

    describe("gets ignored when", function ()
      it("sends an empty table", function ()
        APClient.SEND.LocationScouts({})
        assert.spy(ConnInterface.send).was_not_called()
      end)
    end)

    describe("sends a packet if", function ()
      it("has one id", function ()
        APClient.SEND.LocationScouts({11000})
        self_called_with(ConnInterface.send, '[{"cmd":"LocationScouts","create_as_hint":0,"locations":[11000]}]')
      end)

      it("has a few ids", function ()
        APClient.SEND.LocationScouts({11000, 11001, 11002})
        self_called_with(ConnInterface.send, '[{"cmd":"LocationScouts","create_as_hint":0,"locations":[11000,11001,11002]}]')
      end)

      it("has duplicate ids", function ()
        APClient.SEND.LocationScouts({11000, 11000, 11000})
        self_called_with(ConnInterface.send, '[{"cmd":"LocationScouts","create_as_hint":0,"locations":[11000,11000,11000]}]')
      end)

      describe("create_as_hint", function ()
        it("sends 0 if false", function ()
          APClient.SEND.LocationScouts({11000}, false)
          self_called_with(ConnInterface.send, '[{"cmd":"LocationScouts","create_as_hint":0,"locations":[11000]}]')
        end)

        it("sends 1 if true", function ()
          APClient.SEND.LocationScouts({11000}, true)
          self_called_with(ConnInterface.send, '[{"cmd":"LocationScouts","create_as_hint":1,"locations":[11000]}]')
        end)

        it("sends numbers", function ()
          APClient.SEND.LocationScouts({11000}, 2)
          self_called_with(ConnInterface.send, '[{"cmd":"LocationScouts","create_as_hint":2,"locations":[11000]}]')
        end)
      end)
    end)
  end)

  describe("StatusUpdate", function()
    describe("sends a packet if", function ()
      it("uses any value", function()
        APClient.SEND.StatusUpdate(5)
        self_called_with(ConnInterface.send, '[{"cmd":"StatusUpdate","status":5}]')
      end)

      it("reaches the goal", function()
        APClient.SEND.StatusUpdate(30)
        self_called_with(ConnInterface.send, '[{"cmd":"StatusUpdate","status":30}]')
      end)
    end)
  end)

  describe("Say", function()
    describe("gets ignored when", function ()
      it("has no arguments", function ()
        APClient.SEND.Say()
        assert.spy(ConnInterface.send).was_not_called()
      end)

      it ("sends an empty string", function ()
        APClient.SEND.Say("")
        assert.spy(ConnInterface.send).was_not_called()
      end)
    end)

    describe("sends a packet if", function ()
      it("has a message", function ()
        APClient.SEND.Say("Test Message")
        self_called_with(ConnInterface.send, '[{"cmd":"Say","text":"Test Message"}]')
      end)

      it("has non-ascii characters", function ()
        APClient.SEND.Say("諸島 الأرخبيل দ্বীপপুঞ্জ")
        self_called_with(ConnInterface.send, '[{"cmd":"Say","text":"諸島 الأرخبيل দ্বীপপুঞ্জ"}]')
      end)

      it("has emoji", function ()
        APClient.SEND.Say("😸🧙🏿‍♂️")
        self_called_with(ConnInterface.send, '[{"cmd":"Say","text":"😸🧙🏿‍♂️"}]')
      end)
    end)
  end)

  describe("GetDataPackage", function()
    describe("gets ignored when", function ()
      it("sends an empty table", function ()
        APClient.SEND.GetDataPackage({})
        assert.spy(ConnInterface.send).was_not_called()
      end)
    end)


    describe("sends a packet if", function ()
      it("requests all games", function ()
        APClient.SEND.GetDataPackage()
        self_called_with(ConnInterface.send, '[{"cmd":"GetDataPackage"}]')
      end)

      it("has one game", function ()
        APClient.SEND.GetDataPackage({"Noita"})
        self_called_with(ConnInterface.send, '[{"cmd":"GetDataPackage","games":["Noita"]}]')
      end)

      it("has a few games", function ()
        APClient.SEND.GetDataPackage({"Noita", "Minecraft", "Game"})
        self_called_with(ConnInterface.send, '[{"cmd":"GetDataPackage","games":["Noita","Minecraft","Game"]}]')
      end)

      it("has duplicate games", function ()
        APClient.SEND.GetDataPackage({"Noita", "Noita", "Noita"})
        self_called_with(ConnInterface.send, '[{"cmd":"GetDataPackage","games":["Noita","Noita","Noita"]}]')
      end)
    end)
  end)

  describe("Bounce", function()
    describe("sends a packet if", function ()
      it("is called with nothing", function ()
        APClient.SEND.Bounce()
        self_called_with(ConnInterface.send, '[{"cmd":"Bounce"}]')
      end)

      it("is called with args", function ()
        APClient.SEND.Bounce({
          games = {"Noita", "Dark Souls"},
          slots = {1, 2},
          tags = {"DeathLink", "AP"},
        })
        self_called_with(ConnInterface.send, '[{"cmd":"Bounce","games":["Noita","Dark Souls"],"slots":[1,2],"tags":["DeathLink","AP"]}]')
      end)

      it("is called with data", function ()
        APClient.SEND.Bounce({
          tags = {"DeathLink"},
          data = {
            time = 100.300,
            cause = "stupidity",
            source = "me"
          }
        })
        self_called_with(ConnInterface.send, '[{"cmd":"Bounce","data":{"cause":"stupidity","source":"me","time":100.3},"tags":["DeathLink"]}]')
      end)
    end)
  end)

  describe("Get", function()
    describe("fails if", function ()
      it("has no argument", function ()
        assert.has_errors(function() APClient.SEND.Get() end)
      end)
    end)

    describe("gets ignored when", function ()
      it("sends an empty table", function ()
        APClient.SEND.Get({})
        assert.spy(ConnInterface.send).was_not_called()
      end)
    end)

    describe("sends a packet if", function ()
      it("has one key", function ()
        APClient.SEND.Get({"MyKey"})
        self_called_with(ConnInterface.send, '[{"cmd":"Get","keys":["MyKey"]}]')
      end)

      it("has a few keys", function ()
        APClient.SEND.Get({"MyKey", "NumDogs", "NumCats"})
        self_called_with(ConnInterface.send, '[{"cmd":"Get","keys":["MyKey","NumDogs","NumCats"]}]')
      end)

      it("has duplicate keys", function ()
        APClient.SEND.Get({"MyKey", "MyKey", "MyKey"})
        self_called_with(ConnInterface.send, '[{"cmd":"Get","keys":["MyKey","MyKey","MyKey"]}]')
      end)
    end)
  end)

  describe("Set", function()
    -- TODO
  end)

  describe("SetNotify", function()
    describe("fails if", function ()
      it("has no argument", function ()
        assert.has_errors(function() APClient.SEND.SetNotify() end)
      end)
    end)

    describe("gets ignored when", function ()
      it("sends an empty table", function ()
        APClient.SEND.SetNotify({})
        assert.spy(ConnInterface.send).was_not_called()
      end)
    end)

    describe("sends a packet if", function ()
      it("has one key", function ()
        APClient.SEND.SetNotify({"MyKey"})
        self_called_with(ConnInterface.send, '[{"cmd":"SetNotify","keys":["MyKey"]}]')
      end)

      it("has a few keys", function ()
        APClient.SEND.SetNotify({"MyKey", "NumDogs", "NumCats"})
        self_called_with(ConnInterface.send, '[{"cmd":"SetNotify","keys":["MyKey","NumDogs","NumCats"]}]')
      end)

      it("has duplicate keys", function ()
        APClient.SEND.SetNotify({"MyKey", "MyKey", "MyKey"})
        self_called_with(ConnInterface.send, '[{"cmd":"SetNotify","keys":["MyKey","MyKey","MyKey"]}]')
      end)
    end)
  end)
end)
