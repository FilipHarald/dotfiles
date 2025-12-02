return {
	"ibhagwan/fzf-lua",
	opts = {
		fzf_opts = {
			["--no-scrollbar"] = true,
			["--history"] = vim.fn.stdpath("data") .. "/fzf-history",
		},
		winopts = {
			width = 0.9,
			height = 0.9,
			row = 0.5,
			col = 0.5,
			preview = {
				scrollchars = { "┃", "" },
			},
		},
	},
	keys = {
		{
			"<leader><leader>f",
			function()
				local current_file = vim.fn.expand("%")
				local current_dir = vim.fn.fnamemodify(current_file, ":h")
				local relative_dir = vim.fn.fnamemodify(current_dir, ":.")
				require("fzf-lua").files({
					query = relative_dir .. "/",
				})
			end,
			desc = "Find neighboring files",
		},
	},
}
