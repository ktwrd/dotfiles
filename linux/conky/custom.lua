local services = {
	"docker.service",
	"nginx",
	"php8.4-fpm",
	"syncthing@kate",
	"clamav-daemon.service"
}

local services_rename = {
	["docker.service"] = "docker",
	["syncthing@kate"] = "syncthing",
	["clamav-daemon.service"] = "clamav-daemon"
}
local service_status_colors = {
	["active (running)"] = "green",
	["inactive (dead)"] = "white"
}

local kate_cfg = {
	['network_interface'] = "enp90s0",
	-- ordered from most important (picked first) to least important
	['audio_players'] = {
		"strawberry"
	},
	['audio_interval'] = 0.5,
	['now_playing_emoji'] = true
}

function conky_service_statuses()
	local display_data = {}
	local max_pfx_len = 0
	
	for i = 1, #services do
		local status = conky_parse("${execi 8 ~/dotfiles/linux/conky/service-status.sh "..services[i].."}")
		local svc_pfx = services[i]
		
		if services_rename[services[i]] ~= nil then
			svc_pfx = services_rename[services[i]]
		end
		
		if max_pfx_len < #svc_pfx then
			max_pfx_len = #svc_pfx
		end

		local svc_value = "${color white}"
		if service_status_colors[status] ~= nil then
			svc_value = "${color "..service_status_colors[status].."}"
		end
		
		svc_value = svc_value..status
		display_data[svc_pfx] = svc_value
	end
	
	local i = 1
	local result = ""
	for key, value in pairs(display_data) do
		local item = "${color white}"..string.format("%"..(max_pfx_len).."s", key)..": "..value
		if i < #services then
			item = item.."\n"
		end
		result = result..item
		i = i + 1
	end
	return result
end

-- get first valid audio player (from playerctl) defined in kate_cfg.audio_players
function playerctl_current_player()
	for i = 1, #kate_cfg['audio_players'] do
		if os.execute("playerctl status -p "..kate_cfg['audio_players'][i].." > /dev/null 2>&1") == true then
			return kate_cfg['audio_players'][i]
		end
	end
	return nil
end
function playerctl_commands()
	local player = playerctl_current_player()
	if player == nil then
		error("[playerctl_commands] could not find any valid players!", 1)
	end
	
	local base = "playerctl -p "..player
	local metadata_base = base.." metadata"
	local result = {
		status = "playerctl status -p "..player,
		artist = metadata_base.." artist",
		album = metadata_base.." album",
		title = metadata_base.." title",
		track_pos = base.." -f '{{duration(position)}}' metadata",
		track_length = base.." -f '{{duration(mpris:length)}}' metadata",
		track_len_info = base.." -f '{{position}}|{{mpris:length}}' metadata"
	}
	return result
end
function kp_execi(interval, command)
	return conky_parse("${execi "..interval.." "..command.."}")
end


function split_to_number(text, by)
	local result = {}
	for token in string.gmatch(text, '([^'..by..']+)') do
		table.insert(result, tonumber(token))
	end
	return result
end
function conky_track_progress()
	local content = kp_execi(0.5, playerctl_commands()['track_len_info'])
	local track_info = split_to_number(content, "|+")
	local result = math.floor((track_info[1] / track_info[2]) * 100)
	if result < 0 then return 0 end
	if result > 100 then return 100 end
	return result
end
function conky_now_playing()
	local cmd = playerctl_commands()
	local interval = kate_cfg['audio_interval']
	local status = kp_execi(interval, cmd['status'])
	local artist = kp_execi(interval, cmd['artist'])
	local title = kp_execi(interval, cmd['title'])
	local album = kp_execi(interval, cmd['album'])
	local pos = kp_execi(interval, cmd['track_pos'])
	local len = kp_execi(interval, cmd['track_length'])

	local invalid_value = "No player could handle this command"
	if status ~= "Playing" and status ~= "Paused" then
		return "$hr"
	end

	local playing_keyword = "Now Playing"
	if status == "Paused" then
		playing_keyword = "PAUSED!"
	end
	local result = "$hr\n${alignc}${font JetBrains Mono NF:size=10:bold}${color2}"..playing_keyword.."${font}\n"
	result = result.."${alignc}${color}"..artist.." - "..title.."\n"
	if album ~= invalid_value then
		result = result.."${color}${alignc}"..album.."\n"
	end
	result = result.."${alignc}"..pos.." ${lua_bar 10,160 conky_track_progress} "..len.."\n"
	return result.."$hr"
end
