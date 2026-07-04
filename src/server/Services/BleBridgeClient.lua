local HttpService = game:GetService("HttpService")

local BleBridgeClient = {}

local function trim(value: string): string
	return value:match("^%s*(.-)%s*$")
end

local function parsePowerValue(value): number?
	if type(value) == "number" then
		return value
	end

	if type(value) == "string" then
		return tonumber(value)
	end

	return nil
end

function BleBridgeClient.parsePowerWatts(responseBody: string): (number?, string?)
	local body = trim(responseBody)

	if body == "" then
		return nil, "empty response"
	end

	local directNumber = tonumber(body)

	if directNumber then
		return directNumber, nil
	end

	local decodeOk, decoded = pcall(function()
		return HttpService:JSONDecode(body)
	end)

	if not decodeOk then
		return nil, "response was not JSON or a number"
	end

	local decodedType = type(decoded)

	if decodedType == "number" or decodedType == "string" then
		return parsePowerValue(decoded), nil
	end

	if decodedType ~= "table" then
		return nil, "response JSON did not contain power"
	end

	if decoded.connected == false then
		return nil, "bridge disconnected"
	end

	if decoded.stale == true then
		return nil, "power data stale"
	end

	local candidates = {
		decoded.powerWatts,
		decoded.power,
		decoded.watts,
		decoded.instantaneousPower,
	}

	for _, candidate in candidates do
		local powerWatts = parsePowerValue(candidate)

		if powerWatts then
			return powerWatts, nil
		end
	end

	return nil, "response JSON did not contain powerWatts, power, watts, or instantaneousPower"
end

function BleBridgeClient.fetchPowerWatts(config): (number?, string?)
	local response

	local requestOk, requestError = pcall(function()
		response = HttpService:RequestAsync({
			Url = config.Endpoint,
			Method = "GET",
			Timeout = config.RequestTimeoutSeconds,
		})
	end)

	if not requestOk then
		return nil, `request failed: {requestError}`
	end

	if not response.Success then
		return nil, `endpoint returned {response.StatusCode} {response.StatusMessage}`
	end

	return BleBridgeClient.parsePowerWatts(response.Body)
end

function BleBridgeClient.startPolling(config, onSample)
	local isRunning = true

	task.spawn(function()
		while isRunning do
			local powerWatts, errorMessage = BleBridgeClient.fetchPowerWatts(config)

			if powerWatts then
				onSample({
					ok = true,
					powerWatts = powerWatts,
					errorMessage = "",
				})
			else
				onSample({
					ok = false,
					powerWatts = config.FallbackPowerWatts,
					errorMessage = errorMessage or "unknown bridge error",
				})
			end

			task.wait(config.PollIntervalSeconds)
		end
	end)

	return function()
		isRunning = false
	end
end

return BleBridgeClient
