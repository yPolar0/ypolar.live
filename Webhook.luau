local Get = setmetatable({ }, { __index = function(Self, Index)
    return cloneref(game.GetService(game, Index));
end })

local HttpService = Get.HttpService;

local Webhook = { }; do
    Webhook.__index = Webhook;

    function Webhook.IsValidUrl(Url)
        assert(typeof(Url) == "string", "Webhook URL must be a string")

        return Url:find("https://discord.com/api/webhooks/", 1, true) or Url:find("https://discordapp.com/api/webhooks/", 1, true) or Url:find("https://webhook.lewisakura.moe/api/webhooks/", 1, true);
    end

    function Webhook.new(Url)
        assert(Webhook.IsValidUrl(Url), "Invalid Discord webhook URL")

        local self = setmetatable({ }, Webhook)
        self._Url = Url

        return self;
    end

    function Webhook:Send(Data, Yields)
        if (typeof(Data) == 'string') then
            Data = { content = Data };
        end

        local Send = function()
            request({
                Url = self._Url,
                Method = 'POST',
                Headers = {['Content-Type'] = 'application/json'},
                Body = HttpService:JSONEncode(HttpService, Data)
            });
        end

        if (Yields) then
            pcall(Send);
        else
            task.spawn(Send);
        end
    end
end

return Webhook;
