--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd("lspattach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		-- note: remember that lua is a real programming language, and as such it is possible
		-- to define small helper and utility functions so you don't have to repeat yourself.
		--
		-- in this case, we create a function that lets us more easily define mappings specific
		-- for lsp related items. it sets the mode, buffer and description for us each time.
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "lsp: " .. desc })
		end

		-- the following two autocommands are used to highlight references of the
		-- word under your cursor when your cursor rests there for a little while.
		--    see `:help cursorhold` for information about when this is executed
		--
		-- when you move your cursor, the highlights will be cleared (the second autocommand).
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "cursorhold", "cursorholdi" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "cursormoved", "cursormovedi" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("lspdetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		-- the following code creates a keymap to toggle inlay hints in your
		-- code, if the language server you are using supports them
		--
		-- this may be unwanted, since they displace some of your code
		if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			map("<leader>uh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[t]oggle inlay [h]ints")
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
	pattern = { "scala", "sbt", "java" },
	callback = function()
		require("metals").initialize_or_attach(require("metals").bare_config())
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("codecompanion-chat", { clear = true }),
	pattern = { "codecompanion" },
	callback = function()
		vim.keymap.set("n", "q", "<cmd>:bd<cr>", { silent = true })
	end,
})
