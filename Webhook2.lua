-- // Types
export type EmbedData = {
	["title"]: string | nil,
	["description"]: string | nil,
	["url"]: string | nil,
	["timestamp"]: string | nil,
	["color"]: number | nil,
	["footer"]: {["text"]: string,["icon_url"]: string | nil} | nil,
	["author"]: {["name"]: string,["url"]: string | nil,["icon_url"]: string | nil} | nil,
	["fields"]: {{["name"]: string,["value"]: string,["inline"]: boolean | nil}?} | nil
}

export type WebhookData = {
	["content"]: string | nil,
	["username"]: string | nil,
	["avatar_url"]: string | nil,
	["tts"]: boolean | nil,
	["embeds"]: {[number]: EmbedData} | nil,
}

-- // Services
local Get = setmetatable({}, {
	__index = function(_, Index)
		return cloneref(game:GetService(Index))
	end
})

local HttpService = Get.HttpService

-- // Module
local WebhookService = { }; do
	local IsRequestRateLimited = false

	local Embed = {}
	Embed.__index = Embed

	local Webhook = {}
	Webhook.__index = Webhook

	-- // Internal
    local function ValidateWebhookUrl(Url)
        assert(typeof(Url) == "string", "WebhookUrl must be a string")

        return Url:find("https://discord.com/api/webhooks/", 1, true) or Url:find("https://discordapp.com/api/webhooks/", 1, true) or Url:find("https://webhook.lewisakura.moe/api/webhooks/", 1, true);
    end
    
	local function ValidateWebhookObject(WebhookObject)
		return WebhookObject and WebhookObject.Data and (WebhookObject.Data.content or WebhookObject.Data.embeds);
	end

	local function SendRequest(WebhookObject, WebhookUrl)
		if IsRequestRateLimited then
			repeat task.wait(1) until not IsRequestRateLimited
		end

		local Response = request({
			Url = WebhookUrl,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(WebhookObject.Data)
		});

		if Response.StatusCode == 429 then
			local RetryAfter =Response.Headers["ratelimit-reset"] or Response.Headers["retry_after"]

			if RetryAfter then
				IsRequestRateLimited = true
				task.wait(tonumber(RetryAfter))
				IsRequestRateLimited = false
				return SendRequest(WebhookObject, WebhookUrl);
			end
		end

		return {
			Success = Response.StatusCode == 200,
			Code = Response.StatusCode
		};
	end

	function WebhookService:CreateEmbed(Data)
		local self = setmetatable({}, Embed)
		self.Data = Data or { }
		return self;
	end

	function WebhookService:CreateWebhook(Data)
		local self = setmetatable({}, Webhook)
		self.Data = Data or { }
		return self;
	end

	function WebhookService:SendAsync(WebhookObject, WebhookUrl)
		assert(WebhookObject, "WebhookObject is required")
		assert(WebhookUrl, "WebhookUrl is required")
        assert(ValidateWebhookUrl(WebhookUrl), "Invalid Discord webhook url")
		assert(ValidateWebhookObject(WebhookObject), "Invalid webhook payload")

		local _, Response = pcall(function()
			return SendRequest(WebhookObject, WebhookUrl);
		end)

		return Response;
	end

    -- // Webhook
	function Webhook:SetMessage(Message)
		self.Data.content = Message
		return self;
	end

	function Webhook:SetUsername(Username)
		self.Data.username = Username
		return self;
	end

	function Webhook:SetAvatar(Avatar)
		self.Data.avatar_url = Avatar
		return self;
	end

	function Webhook:SetTTS(TTS)
		self.Data.tts = TTS
		return self;
	end

	function Webhook:AddEmbed(EmbedObject)
		self.Data.embeds = self.Data.embeds or { }
		table.insert(self.Data.embeds, EmbedObject.Data)
		return self;
	end

	-- // Embed
	function Embed:SetTitle(Title)
		self.Data.title = Title
		return self;
	end

	function Embed:SetDescription(Description)
		self.Data.description = Description
		return self;
	end

	function Embed:SetURL(Url)
		self.Data.url = Url
		return self;
	end

	function Embed:SetTimestamp(Timestamp)
		self.Data.timestamp = Timestamp or DateTime.now():ToIsoDate()
		return self;
	end

	function Embed:SetColor(Color)
		self.Data.color = tonumber(Color:ToHex(), 16)
		return self;
	end

	function Embed:SetFooter(Text, Icon)
		self.Data.footer = { text = Text, icon_url = Icon }
		return self;
	end

	function Embed:SetAuthor(Name, URL, Icon)
		self.Data.author = { name = Name, url = URL, icon_url = Icon }
		return self;
	end

	function Embed:AddField(Name, Value, Inline)
		self.Data.fields = self.Data.fields or { }
		table.insert(self.Data.fields, {
			name = Name,
			value = Value,
			inline = Inline
		})
		return self;
	end
end

return WebhookService;
