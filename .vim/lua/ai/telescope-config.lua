local previewers = require('telescope.previewers')
local putils = require('telescope.previewers.utils')
local pfiletype = require('plenary.filetype')

local actions = require('telescope.actions')
local telescope = require('telescope')

-- https://github.com/nvim-telescope/telescope.nvim/issues/857#issuecomment-846368690
local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}
  if opts.use_ft_detect == nil then
    local ft = pfiletype.detect(filepath)
    -- Here for example you can say: if ft == "xyz" then this_regex_highlighing else nothing end
    opts.use_ft_detect = false
    putils.regex_highlighter(bufnr, ft)
  end
  previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

local M = {}

M.project_files = function()
  -- local opts = require('telescope.themes').get_dropdown({  winblend = 10 })
  local opts = {}
  local ok = pcall(require'telescope.builtin'.git_files, opts)
  if not ok then
    require'telescope.builtin'.find_files(opts)
  end
end

M.livegrep_project = function()
  require('telescope.builtin').live_grep({})
end

M.grep_string_hidden = function()
  require('telescope.builtin').grep_string({})
end

telescope.setup {
  defaults = {
    buffer_previewer_maker = new_maker,
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    scroll_strategy = "cycle",
    selection_strategy = "reset",
    layout_strategy = "flex",
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    layout_config = { horizontal = { width = 0.6 }, vertical = { width = 0.5 } },
    mappings = {
      i = {
        ["<C-s-v>"] = actions.select_vertical,
        ["<esc>"] = actions.close,
        ["<C-t>"] = false,
        ["<C-u>"] = false,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
}

telescope.load_extension('frecency')
telescope.load_extension('fzf')

-- Unused

local lower_ivy = function(opts)
  opts = opts or {}
  return require("telescope.themes").get_ivy(
             vim.tbl_extend(
                 "force", { layout_config = { height = 12 } }, opts
             )
         )
end

M.frecency = function()
  require("telescope").extensions.frecency.frecency(lower_ivy())
end

M.buffers = function()
  require("telescope.builtin").buffers(lower_ivy())
end

M.git_branches = function()
  require("telescope.builtin").git_branches(lower_ivy())
end

return M
