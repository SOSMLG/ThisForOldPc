-- Minimal Neovim config for coding on old+modern hardware
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 300
vim.g.mapleader = " "

-- Keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>e", ":Ex<CR>")

-- Basic LSP (if available)
local ok, lsp = pcall(require, "lspconfig")
if ok then
  lsp.pyright.setup({})
  lsp.ts_ls.setup({})
  lsp.clangd.setup({})
end
