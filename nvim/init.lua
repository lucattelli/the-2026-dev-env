vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0

local augroup = vim.api.nvim_create_augroup("MyConfig", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.hl.on_yank({ timeout = 40 })
    end,
})

vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    command = "wincmd =",
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts)
    end,
})


vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostics" })
vim.keymap.set("n", "<leader>fe", ":Ex<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>o", "<cmd>update | source<CR>", { desc = "Reload configuration" })
vim.keymap.set("v", "<", "<gv", { desc = "Remove ident" })
vim.keymap.set("v", ">", ">gv", { desc = "Add ident" })
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })

vim.o.cmdheight = 2
vim.o.colorcolumn = '120'
vim.o.complete = "i"
vim.o.completeopt = "menu,menuone,noselect"
vim.o.errorbells = true
vim.o.expandtab = true
vim.o.fileformat = "unix"
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.list = true
vim.o.mouse = "a"
vim.o.nu = true
vim.o.rnu = true
vim.o.scrolloff = 10
vim.o.shiftwidth = 0
vim.o.sidescrolloff = 10
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.softtabstop = 0
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.undofile = false
vim.o.updatetime = 250
vim.o.winborder = "rounded"
vim.o.wrap = false

vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" }, -- mason-lspconfig dep
    { src = "https://github.com/mason-org/mason.nvim" },  -- mason-lspconfig dep
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/nvim-mini/mini.pick", version = "stable" },
    { src = "https://github.com/nvim-mini/mini.notify", version = "stable" },
})
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "lua_ls", "gopls" },
})
require("mini.pick").setup()
require("mini.notify").setup()

local pick = require("mini.pick")
vim.keymap.set("n", "<leader>ff", pick.builtin.files, { desc = "Search files" })
vim.keymap.set("n", "<leader>fg", pick.builtin.grep_live, { desc = "Search text" })
vim.keymap.set("n", "<leader>fb", pick.builtin.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fh", pick.builtin.help, { desc = "Help" })
vim.keymap.set("n", "<leader>fr", pick.builtin.resume, { desc = "Reopen last search" })

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
                preloadFileSize = 10000,
                library = { vim.env.VIMRUNTIME },
            },
        }
    }
})

vim.lsp.config("gopls", {
    cmd = {'gopls', '-remote=auto'},
    init_options = { staticcheck = true },
})

