local config = require("leetbuddy.config")

M = {}


M.Debug = function(v)
    if config.debug then
        print(vim.inspect(v))
    end
    return v
end

M.P = function(v)
    print(vim.inspect(v))
    return v
end

return M
