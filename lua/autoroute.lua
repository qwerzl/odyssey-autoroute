--   redis-cli SADD deviceId x.x.x.x
--   redis-cli SREM deviceId x.x.x.x
--   https://github.com/agentzh/lua-resty-redis
--
-- your nginx http context should contain something similar to the
-- below: (assumes resty/redis.lua exists in /etc/nginx/lua/)
--
--   lua_package_path "/etc/nginx/lua/?.lua;;";
--   lua_shared_dict autoroute 1m;
--
-- you can then use the below (adjust path where necessary) to check
-- against the blacklist in a http, server, location, if context:
--
-- access_by_lua_file /etc/nginx/lua/autoroute.lua;
--
-- modified from https://gist.github.com/chrisboulton/6043871

local redis_host    = "127.0.0.1"
local redis_port    = 6379

-- connection timeout for redis in ms. don't set this too high!
local redis_connection_timeout = 100

-- end configuration

local deviceId = ngx.var.arg_deviceId

-- START
if deviceId then
	ngx.log(ngx.DEBUG, "deviceId: " .. deviceId);
	local autoroute, err = red:smembers(deviceId);
	if err then
		ngx.log(ngx.DEBUG, "Redis read error while retrieving autoroute: " .. err);
	else
		for index, route in ipairs(new_autoroute) do
			selectedRoute = route;
		end
		ngx.log(ngx.DEBUG, "selectedRoute for deviceId " .. deviceId .. ": " .. selectedRoute)
                ngx.log(ngx.DEBUG, "Redirecting for deviceId " .. deviceId .. "to: " .. "http://newhost.com" .. ngx.var.request_uri) 
		ngx.redirect("http://newhost.com" .. ngx.var.request_uri, ngx.HTTP_MOVED_TEMPORARILY, ngx.req.get_headers())
	end
end
-- END
