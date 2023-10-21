-- ~/.hammerspoon/init.lua

-- I had originally attempted to use the `fennel` package available via luarocks, similar to what is recommended with Spacehammer
-- However, I was unable to get the `package.path` or `package.cpath` configured correctly to successfully `require('fennel')`.
-- As a workaround, I've embedded the `fennel.lua` source file within the `.hammerspoon/` directory.
--
--     wget https://fennel-lang.org/downloads/fennel-1.3.1.tar.gz
--     tar xvzf fennel-1.3.1.tar.gz
--     mv fennel-1.3.1/fennel.lua .
--     rm -r fennel-1.3.1/
--
-- https://fennel-lang.org/setup#embedding-the-fennel-compiler-in-a-lua-application
-- https://github.com/agzam/spacehammer/blob/master/init.lua
-- https://blog.exupero.org/hammerspoon-with-fennel/

local fennel = require('fennel')

fennel.path = package.path .. ";" .. os.getenv("HOME") .. "/.hammerspoon/?.fnl"

table.insert(package.loaders or package.searchers, fennel.searcher)

require 'main'
