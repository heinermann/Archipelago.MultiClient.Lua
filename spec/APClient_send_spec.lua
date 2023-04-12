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
    APClient.InitConnectionInterface(ConnInterface)
  end)

  describe("Connect", function()
    -- TODO
  end)

  describe("ConnectUpdate", function()
    -- TODO
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
    -- TODO
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

      it("has has non-ascii characters", function ()
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
    -- TODO
  end)

  describe("Bounce", function()
    -- TODO
  end)

  describe("Get", function()
    -- TODO
  end)

  describe("Set", function()
    -- TODO
  end)

  describe("SetNotify", function()
    -- TODO
  end)
end)
