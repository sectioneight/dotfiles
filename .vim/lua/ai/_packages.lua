local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn
-- ensure that packer is installed
local install_path = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  execute 'packadd packer.nvim'
end
vim.cmd [[packadd packer.nvim]]

local packer = require('packer')
local util = require('packer.util')
packer.init({ package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack') })

local function init_packer(use)
  use { 'wbthomason/packer.nvim', opt = true }
  -- Fuzzy find everything
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'kyazdani42/nvim-web-devicons' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    },
    config = function()
      require('ai/telescope-config')
    end,
  }

  -- Magit for neovim
  use {
    'TimUntersberger/neogit',
    -- '~/src/neogit',
    requires = {
      'nvim-lua/plenary.nvim',
      {
        "sindrets/diffview.nvim",
        config = function()
          require('ai/_diffview')
        end,
      },
    },
    config = function()
      require('ai/_neogit')
    end,
    cmd = 'Neogit',
  }

  -- Frequency/recency
  use {
    'nvim-telescope/telescope-frecency.nvim',
    requires = { { 'tami5/sql.nvim' } },
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      -- Autoclose HTML/TSX tags
      'windwp/nvim-ts-autotag',
    },
    run = ':TSUpdate',
    config = function()
      require('ai/treesitter-config')
    end,
  }

  -- New status line
  use {
    'glepnir/galaxyline.nvim',
    requires = { 'nvim-lua/lsp-status.nvim' },
    config = function()
      require('ai/_galaxyline')
    end,
  }

  -- Code completion
  use {
    'hrsh7th/nvim-compe',
    config = function()
      require('ai/completion')
    end,
    event = 'InsertEnter *',
  }

  -- Highlight other usages of a symbol under cursor, using LSP
  use { 'RRethy/vim-illuminate' }

  -- Snippets
  use {
    'hrsh7th/vim-vsnip',
    requires = {
      -- Default snippets
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require('ai/_vsnip')
    end,
    event = 'InsertEnter *',
  }

  -- Show type signature when calling functions
  use {
    'ray-x/lsp_signature.nvim',
    config = function()
      require('ai/_lsp_signature')
    end,
  }

  -- Emacs-like keyboard shortcut completion helper
  use {
    'folke/which-key.nvim',
    config = function()
      require('ai/_which-key')
    end,
  }

  -- Use lua for keymapping. Will be builtin to neovim once
  -- https://github.com/neovim/neovim/pull/13823
  -- is merge
  use {
    'tjdevries/astronauta.nvim',
    config = function()
      require('ai/keymappings')
    end,
  }

  use {
    'neovim/nvim-lspconfig',
    requires = {
      'kabouzeid/nvim-lspinstall',
      {
        'glepnir/lspsaga.nvim',
        requires = { 'neovim/nvim-lspconfig' },
        config = function()
          require('ai/_lspsaga')
        end,
      }, -- Extensible linters/formatters
      { 'mattn/efm-langserver', requires = { 'neovim/nvim-lspconfig' } },
    },
    config = function()
      require('ai/_lspinstall')
      require('ai/lua-ls')
      require('ai/typescript')
      require('ai/elixir-config')
    end,
  }

  -- Find and replace
  use 'windwp/nvim-spectre'

  -- Wrapping/delimiters
  use {
    'andymass/vim-matchup',
    setup = [[require('ai/_matchup')]],
    event = 'BufEnter',
  }

  -- Automatically insert endwise pairs
  use { 'tpope/vim-endwise', setup = [[require('ai/_endwise')]] }

  -- Undo tree
  use {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    config = [[require('ai/_undotree')]],
  }

  -- View registers
  use 'tversteeg/registers.nvim'

  -- Floating terminal
  use {
    'voldikss/vim-floaterm',
    cmd = { 'FloatermNew', 'FloatermToggle' },
    config = [[require('ai/_floaterm')]],
  }

  use { 'windwp/nvim-autopairs', config = [[require('ai/_autopairs')]] }
end

--- startup and add configure plugins
packer.startup(init_packer)
