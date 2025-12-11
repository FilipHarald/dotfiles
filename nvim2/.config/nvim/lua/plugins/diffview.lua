return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },

	-- Lazy-load on commands and keybindings
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewFileHistory",
		"DiffviewRefresh",
	},

	keys = {
		{
			"<leader>fh",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "File history (current file)",
		},
	},

	opts = {
		-- Enhanced diff highlighting (subtle delete fill-chars)
		enhanced_diff_hl = false,

		-- Use icons (requires nvim-web-devicons)
		use_icons = true,

		-- Show help hints
		show_help_hints = true,

		view = {
			-- Config for changed files, and staged files in diff views
			default = {
				layout = "diff2_horizontal",
				-- Uncomment to disable diagnostics in diff buffers:
				-- disable_diagnostics = true,
				winbar_info = false,
			},
			-- Config for conflicted files during merge/rebase
			merge_tool = {
				-- Three-way diff: OURS | LOCAL | THEIRS
				layout = "diff3_horizontal",
				disable_diagnostics = true,
				winbar_info = true,
			},
			-- Config for file history views
			file_history = {
				layout = "diff2_horizontal",
				-- Uncomment to disable diagnostics in diff buffers:
				-- disable_diagnostics = true,
				winbar_info = false,
			},
		},

		file_panel = {
			listing_style = "tree",
			tree_options = {
				flatten_dirs = true,
				folder_statuses = "only_folded",
			},
			win_config = {
				position = "left",
				width = 35,
			},
		},

		file_history_panel = {
			win_config = {
				position = "bottom",
				height = 16,
			},
		},

		-- Hooks for customizing diff buffer behavior
		hooks = {
			diff_buf_read = function(bufnr)
				-- Disable line numbers and signs in diff buffers
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				vim.opt_local.signcolumn = "no"
			end,
		},

		-- Default keymaps are enabled
		-- Key merge conflict resolution mappings:
		--   [x, ]x             - Jump between conflict markers
		--   <leader>co         - Choose OURS version
		--   <leader>ct         - Choose THEIRS version
		--   <leader>cb         - Choose BASE version
		--   <leader>ca         - Choose ALL versions
		--   dx                 - Delete conflict region
		--   <leader>gmf        - Obtain hunk from OURS (in 3-way diff)
		--   <leader>gmj        - Obtain hunk from THEIRS (in 3-way diff)
		--   <leader>b          - Toggle file panel
		--   <leader>e          - Focus file panel
		--   <Tab>, <S-Tab>     - Next/prev file
		keymaps = {
			disable_defaults = false,
			diff3 = {
				-- Mappings in 3-way diff layouts
				{
					{ "n", "x" },
					"<leader>gmf",
					function()
						require("diffview.actions").diffget("ours")()
					end,
					{ desc = "Obtain hunk from OURS" },
				},
				{
					{ "n", "x" },
					"<leader>gmj",
					function()
						require("diffview.actions").diffget("theirs")()
					end,
					{ desc = "Obtain hunk from THEIRS" },
				},
			},
		},
	},
}
