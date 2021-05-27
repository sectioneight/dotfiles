local utils = require('utils')


-- Neogit setup
local neogit = require('neogit')
neogit.setup {}

utils.map('n', '<Leader>gg', '<cmd>lua require\'neogit\'.open()<cr>', {noremap = true, silent=true})