local add, later = MiniDeps.add, MiniDeps.later

later(function()
	add({
		source = "christoomey/vim-tmux-navigator",
	})
end)
