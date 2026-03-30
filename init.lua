-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.cursorline = true

-- Sneak config (MUST be set before plugin loads)
vim.g["sneak#label"] = 0
vim.g["sneak#use_ic_scs"] = 1

-- Temporary shim until all plugins switch to the new Treesitter module names.
if not package.loaded["nvim-treesitter.config"] then
  package.preload["nvim-treesitter.config"] = function()
    return require("nvim-treesitter.configs")
  end
end

-- Setup plugins
require("lazy").setup({
  -- Cutlass - d deletes without yanking, m cuts
  -- {
  --   "gbprod/cutlass.nvim",
  --   config = function()
  --     require("cutlass").setup({
  --       cut_key = "m",  -- Use m for cut instead of x
  --       override_del = true,  -- d/D/c/C don't yank
  --     })
  --     -- Remap x to ReplaceWithRegister
  --     vim.keymap.set({'n', 'x'}, 'x', '<Plug>ReplaceWithRegisterOperator', { desc = "Replace with register" })
  --     -- Remap <leader>x to set mark (label)
  --     vim.keymap.set('n', '<leader>x', 'm', { noremap = true, desc = "Set mark (label)" })
  --   end,
  -- },

  -- Highlightedyank - highlight yanked text
  {
    "machakann/vim-highlightedyank",
      config = function()
      vim.g.highlightedyank_highlight_duration = 300 -- ms
      vim.g.highlightedyank_highlight_color = 'Visual'
    end,
  },

  -- Targets.vim - better text objects (cin", cin(, etc.)
  {
    "wellle/targets.vim",
  },

  -- Sneak - commented out, using Flash for s/S instead
  -- {
  --   "justinmk/vim-sneak",
  --   lazy = false,
  --   config = function()
  --     vim.cmd([[
  --       map s <Plug>Sneak_s
  --       map S <Plug>Sneak_S
  --       map f <Plug>Sneak_f
  --       map F <Plug>Sneak_F
  --       map t <Plug>Sneak_t
  --       map T <Plug>Sneak_T
  --     ]])
  --   end,
  -- },

  -- Flash - enhanced search with labels on / and ?
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = true },  -- label matches when using / and ?
        char = { enabled = false },    -- keep vim-sneak for f/F/t/T/s/S
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Surround - ys, ds, cs for adding/deleting/changing surroundings
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- ReplaceWithRegister - r to replace with register contents
  {
    "vim-scripts/ReplaceWithRegister",
    config = function()
      vim.keymap.set('n', 'r', '<Plug>ReplaceWithRegisterOperator', { desc = "Replace with register" })
      vim.keymap.set('n', 'rr', '<Plug>ReplaceWithRegisterLine', { desc = "Replace line with register" })
      vim.keymap.set('x', 'r', '<Plug>ReplaceWithRegisterVisual', { desc = "Replace selection with register" })
    end,
  },

  -- Treesitter configured centrally
  {
    "nvim-treesitter/nvim-treesitter",
    version = "v0.9.3",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c_sharp", "lua", "typescript", "javascript", "python" },
        sync_install = false,
        highlight = {
          enable = not vim.g.vscode,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer", 
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["mf"] = "@function.outer",
              ["ma"] = "@parameter.inner",
              ["mc"] = "@class.outer",
            },
            goto_previous_start = {
              ["Mf"] = "@function.outer",
              ["Ma"] = "@parameter.inner",
              ["Mc"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Ensure ReplaceWithRegister 'gr' mapping is set
-- vim.keymap.set({'n', 'x'}, 'gr', '<Plug>ReplaceWithRegisterOperator', { desc = 'Replace with register' })

-- Treesitter navigation remaps (faster access)
-- vim.keymap.set('n', '<leader>f', '[f', { desc = 'Previous function start' })
-- vim.keymap.set('n', '<leader>F', ']f', { desc = 'Next function start' })

if vim.g.vscode then
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  vim.keymap.set('n', '<leader>i', function()
    vim.fn.VSCodeNotify('breadcrumbs.focus')
  end, { noremap = true, silent = true, desc = "Focus breadcrumbs" })

  -- markdown preview
  map('n', '<leader>kp', function() vim.fn.VSCodeNotify('markdown.showPreview') end, opts)

  -- debug (AstroNvim-style <leader>d group)
  map('n', '<leader>db', function() vim.fn.VSCodeNotify('editor.debug.action.toggleBreakpoint') end, opts)
  map('n', '<leader>dB', function() vim.fn.VSCodeNotify('workbench.debug.viewlet.action.removeAllBreakpoints') end, opts)
  map('n', '<leader>dc', function() vim.fn.VSCodeNotify('workbench.action.debug.continue') end, opts)
  map('n', '<leader>dS', function() vim.fn.VSCodeNotify('workbench.action.debug.start') end, opts)
  map('n', '<leader>dC', function() vim.fn.VSCodeNotify('editor.debug.action.conditionalBreakpoint') end, opts)
  map('n', '<leader>di', function() vim.fn.VSCodeNotify('workbench.action.debug.stepInto') end, opts)
  map('n', '<leader>do', function() vim.fn.VSCodeNotify('workbench.action.debug.stepOver') end, opts)
  map('n', '<leader>dO', function() vim.fn.VSCodeNotify('workbench.action.debug.stepOut') end, opts)
  map('n', '<leader>dp', function() vim.fn.VSCodeNotify('workbench.action.debug.pause') end, opts)
  map('n', '<leader>dr', function() vim.fn.VSCodeNotify('workbench.action.debug.restart') end, opts)
  map('n', '<leader>ds', function() vim.fn.VSCodeNotify('workbench.action.debug.stop') end, opts)
  map('n', '<leader>du', function() vim.fn.VSCodeNotify('workbench.view.debug') end, opts)
  map('n', '<leader>dl', function() vim.fn.VSCodeNotify('workbench.debug.action.toggleRepl') end, opts)
  map('n', '<leader>de', function() vim.fn.VSCodeNotify('editor.debug.action.selectionToWatch') end, opts)
  map('n', '<leader>df', function() vim.fn.VSCodeNotify('editor.debug.action.runToCursor') end, opts)

  -- test
  map('n', '<leader>tt', function() vim.fn.VSCodeNotify('testing.debugAtCursor') end, opts)

  -- copilot chat
  map('n', '<leader>ke', function() vim.fn.VSCodeNotify('github.copilot.chat.explain') end, opts)

  -- utils / important
  map('n', '<leader>r', function() vim.fn.VSCodeNotify('editor.action.rename') end, opts)

  -- LSP direct mappings (AstroNvim-style)
  map('n', 'K', function() vim.fn.VSCodeNotify('editor.action.showHover') end, opts)
  map('n', 'gd', function() vim.fn.VSCodeNotify('editor.action.revealDefinition') end, opts)
  map('n', 'gD', function() vim.fn.VSCodeNotify('editor.action.revealDeclaration') end, opts)
  map('n', 'gi', function() vim.fn.VSCodeNotify('editor.action.goToImplementation') end, opts)
  map('n', 'grr', function() vim.fn.VSCodeNotify('editor.action.goToReferences') end, opts)
  map('n', 'grn', function() vim.fn.VSCodeNotify('editor.action.rename') end, opts)
  map('n', 'gra', function() vim.fn.VSCodeNotify('editor.action.quickFix') end, opts)
  map('n', 'gri', function() vim.fn.VSCodeNotify('editor.action.goToImplementation') end, opts)
  map('n', 'grt', function() vim.fn.VSCodeNotify('editor.action.goToTypeDefinition') end, opts)
  map('n', '[d', function() vim.fn.VSCodeNotify('editor.action.marker.prev') end, opts)
  map('n', ']d', function() vim.fn.VSCodeNotify('editor.action.marker.next') end, opts)

  -- LSP leader group (AstroNvim-style <leader>l)
  map('n', '<leader>la', function() vim.fn.VSCodeNotify('editor.action.quickFix') end, opts)
  map('n', '<leader>ld', function() vim.fn.VSCodeNotify('editor.action.showHover') end, opts)
  map('n', '<leader>lD', function() vim.fn.VSCodeNotify('workbench.actions.view.problems') end, opts)
  map('n', '<leader>lf', function() vim.fn.VSCodeNotify('editor.action.formatDocument') end, opts)
  map('n', '<leader>lh', function() vim.fn.VSCodeNotify('editor.action.triggerParameterHints') end, opts)
  map('n', '<leader>li', function() vim.fn.VSCodeNotify('workbench.action.showAllSymbols') end, opts)
  map('n', '<leader>lr', function() vim.fn.VSCodeNotify('editor.action.rename') end, opts)
  map('n', '<leader>ls', function() vim.fn.VSCodeNotify('workbench.action.gotoSymbol') end, opts)
  map('n', '<leader>lS', function() vim.fn.VSCodeNotify('outline.focus') end, opts)

  -- go to (extras)
  map('n', '<leader>ge', function() vim.fn.VSCodeNotify('workbench.files.action.showActiveFileInExplorer') end, opts)
  map('n', '<leader>gf', function() vim.fn.VSCodeNotify('workbench.action.compareEditor.openSide') end, opts)
  

  -- sidebar
  map('n', '<leader>e', function() vim.fn.VSCodeNotify('workbench.view.explorer') end, opts)

  -- find / search (AstroVim-style <leader>f group)
  map('n', '<leader>ff', function() vim.fn.VSCodeNotify('workbench.action.quickOpen') end, opts)
  map('n', '<leader>fw', function() vim.fn.VSCodeNotify('workbench.action.findInFiles') end, opts)
  map('n', '<leader>fb', function() vim.fn.VSCodeNotify('workbench.action.showAllEditors') end, opts)
  map('n', '<leader>fo', function() vim.fn.VSCodeNotify('workbench.action.openRecent') end, opts)
  map('n', '<leader>fc', function() vim.fn.VSCodeNotify('workbench.action.showCommands') end, opts)
  map('n', '<leader>fk', function() vim.fn.VSCodeNotify('workbench.action.openGlobalKeybindings') end, opts)
  map('n', '<leader>fs', function() vim.fn.VSCodeNotify('workbench.action.gotoSymbol') end, opts)
  map('n', '<leader>fS', function() vim.fn.VSCodeNotify('workbench.action.showAllSymbols') end, opts)
  map('n', '<leader>fp', function() vim.fn.VSCodeNotify('projectManager.listProjects') end, opts)
  
  -- When running under vscode-neovim, toggle the VS Code cursor style
  local ok, vscode = pcall(require, 'vscode')
  if ok and vscode.update_config then
    vim.api.nvim_create_autocmd({'InsertEnter','InsertLeave'}, {
      callback = function(ev)
        if ev.event == 'InsertEnter' then
          vscode.update_config('editor.cursorStyle', 'line', 'workspace')
        else
          vscode.update_config('editor.cursorStyle', 'block', 'workspace')
        end
      end,
    })
  end

  -- Force Normal mode when entering a buffer in VSCode Neovim (prevents unwanted Visual mode)
  local function leave_visual_if_needed()
    vim.cmd("stopinsert")
    if vim.fn.mode():find("[vV\22]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end
  end
end
