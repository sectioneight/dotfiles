local ts = require 'nvim-treesitter.configs'
ts.setup {
  ensure_installed = {
    'bash',
    'clojure',
    'css',
    'dockerfile',
    'erlang',
    'go',
    'graphql',
    'javascript',
    'json',
    'lua',
    'ruby',
    'rust',
    'svelte',
    'toml',
    'tsx',
    'typescript',
    'yaml',
  },
  highlight = {
    enable = true,
    disable = {
      -- These are all too slow to be usable
      "elixir",
      "typescript",
      "tsx",
    },
  },
  indent = {
    enable = true,
    disable = {
      -- This one doesn't work right
      "typescript",
    },
  },
  autotag = {
    enable = true,
    filetypes = { "html", "typescriptreact", "javascriptreact" },
  },
}
