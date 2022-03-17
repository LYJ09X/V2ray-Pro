-- file: lua/Halt.lua

local http = require 'http'
local backend = require 'backend'


local char = string.char
local byte = string.byte
local find = string.find
local sub = string.sub

local ADDRESS = backend.ADDRESS
local PROXY = backend.PROXY
local DIRECT_WRITE = backend.SUPPORT.DIRECT_WRITE

local SUCCESS = backend.RESULT.SUCCESS
local HANDSHAKE = backend.RESULT.HANDSHAKE
local DIRECT = backend.RESULT.DIRECT

local ctx_uuid = backend.get_uuid
local ctx_proxy_type = backend.get_proxy_type
local ctx_address_type = backend.get_address_type
local ctx_address_host = backend.get_address_host
local ctx_address_bytes = backend.get_address_bytes
local ctx_address_port = backend.get_address_port
local ctx_write = backend.write
local ctx_free = backend.free
local ctx_debug = backend.debug

local is_http_request = http.is_http_request

local flags = {}
local marks = {}
local kHttpHeaderSent = 1
local kHttpHeaderRecived = 2

function wa_lua_on_flags_cb(ctx)
    return 0
end

function wa_lua_on_handshake_cb(ctx)
    local uuid = ctx_uuid(ctx)

    if flags[uuid] == kHttpHeaderRecived then
        return true
    end
    
    local res = nil
    

    if flags[uuid] ~= kHttpHeaderSent then
        local host = ctx_address_host(ctx)
        local port = ctx_address_port(ctx)
        

        res = 'CONNECT ' .. host .. ':' .. port ..'@tms.dingtalk.com:80 HTTP/1.1\r\n' ..
                    'Host: tms.dingtalk.com:80\r\n' ..
                    'Proxy-Connection: Keep-Alive\r\n'..
                    'X-T5-Auth: YTY0Nzlk\r\n\r\n'
          
        ctx_write(ctx, res)
        flags[uuid] = kHttpHeaderSent
    end

    return false
end

function wa_lua_on_read_cb(ctx, buf)

    local uuid = ctx_uuid(ctx)
    if flags[uuid] == kHttpHeaderSent then
        flags[uuid] = kHttpHeaderRecived
        return HANDSHAKE, nil
    end

    return DIRECT, buf
end

function wa_lua_on_write_cb(ctx, buf)
 
    local host = ctx_address_host(ctx)
    local port = ctx_address_port(ctx)
    
    if ( is_http_request(buf) == 1 ) then
            local index = find(buf, '/')
            local method = sub(buf, 0, index - 1)
            local rest = sub(buf, index)
            local s, e = find(rest, '\r\n')
            
            local less = sub(rest, e + 1)
            local s1, e1 = find(less, '\r\n')

            buf = method .. sub(rest, 0, e) ..  
            --'X-Online-Host:\t\t ' .. host ..'\r\n' ..
            '\tHost: tms.dingtalk.com:80\r\n'..
            'X-T5-Auth: YTY0Nzlk\r\n' ..
            sub(rest, e + 1)
            
    end
    
    return DIRECT, buf
end

function wa_lua_on_close_cb(ctx)
    local uuid = ctx_uuid(ctx)
    flags[uuid] = nil
    ctx_free(ctx)
    return SUCCESS
end