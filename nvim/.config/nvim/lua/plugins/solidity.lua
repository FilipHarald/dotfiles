return {
	"stevearc/conform.nvim",
	opts = {
		-- log_level = vim.log.levels.DEBUG,
		formatters = {
			forge_fmt = {
				-- Set cwd to the directory containing foundry.toml
				cwd = require("conform.util").root_file({ "foundry.toml" }),
			},
		},
	},
}
