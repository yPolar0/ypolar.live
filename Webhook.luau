local HttpService = cloneref("HttpService");

local Webhook = {};
Webhook.__index = Webhook;

function Webhook.new(Url)
    local self = setmetatable({}, Webhook);

    self._Url = Url;

    return self;
end;

function Webhook:Send(Data, Yields)
    if (typeof(Data) == 'string') then
        data = {content = Data};
    end;

    local function send()
        request({
            Url = self._Url,
            Method = 'POST',
            Headers = {['Content-Type'] = 'application/json'},
            Body = HttpService:JSONEncode(HttpService, Data)
        });
    end;

    if (Yields) then
        pcall(send);
    else
        task.spawn(send);
    end;
end;

return Webhook;
