return {
	dir = "/home/filip/c/eth.nvim",
	config = function()
		require("eth").setup({
			networks = {
				{ "Mainnet", "https://etherscan.io" },
				{ "Sepolia", "https://sepolia.etherscan.io" },
			},
			browser_cmd = nil, -- Auto-detect (xdg-open on Linux, open on macOS)
			cast_cmd = "cast",
			keymaps = {
				mappings = {
					print_address = "<leader>zea",
					get_balance = "<leader>zegb",
					goto_address = "<leader>zeba",
					goto_tx = "<leader>zebt",
				},
			},
		})
	end,
}
