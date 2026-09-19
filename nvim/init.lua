vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = ":%s/\\s\\+$//e",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ timeout = 40 })
    end,
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
})

vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    command = "wincmd =",
})

vim.cmd("colorscheme default")
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, desc = "Open diagnostics" })
vim.keymap.set("n", "<leader>fe", ":Ex<CR>", { noremap = true, desc = "Open file explorer" })
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { noremap = true, desc = "Reload configuration" })
vim.keymap.set("n", "Y", "y$", { noremap = true, desc = "Yank entire line" })
vim.keymap.set("v", "<", "<gv", { noremap = true, desc = "Remove ident" })
vim.keymap.set("v", ">", ">gv", { noremap = true, desc = "Add ident" })
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, desc = "Yank to clipboard" })

vim.o.autoindent = true
vim.o.autoread = true
vim.o.backspace = "indent,eol,start"
vim.o.backup = false
vim.o.cmdheight = 2
vim.o.colorcolumn = '120'
vim.o.complete = "i"
vim.o.completeopt = "menu,menuone,noselect"
vim.o.encoding = "utf-8"
vim.o.errorbells = true
vim.o.expandtab = true
vim.o.fileformat = "unix"
vim.o.hidden = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.laststatus = 2
vim.o.list = true
vim.o.mouse = "a"
vim.o.nu = true
vim.o.rnu = true
vim.o.scrolloff = 10
vim.o.shiftwidth = 0
vim.o.shortmess = "o"
vim.o.sidescrolloff = 10
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.softtabstop = 0
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.undodir = "~/.local/share/nvim/undodir"
vim.o.undofile = false
vim.o.updatetime = 250
vim.o.wildmenu = true
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
require("mason-lspconfig").setup()
require("mini.pick").setup()
require("mini.notify").setup()

local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', '<leader>e', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)

    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
end

vim.lsp.config("lua_ls", {
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 },
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
vim.lsp.enable("lua_ls")

vim.lsp.config("gopls", {
    cmd = {'gopls', '-remote=auto'},
    on_attach = on_attach,
    flags = { debounce_text_changes = 1000 },
    filetypes = {"go"},
    root_markers = { "go_mod, .git" },
    init_options = { staticcheck = true },
})
vim.lsp.enable("gopls")

