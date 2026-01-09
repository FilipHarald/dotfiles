return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  ft = "markdown",
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/obsidian/filip/",
      },
    },

    -- Daily notes configuration
    daily_notes = {
      folder = "notes/daily",
      date_format = "%Y-%m-%d",
      alias_format = "%a %d %b",
      template = "daily.md",
    },

    -- Custom note_id_func: preserves daily note IDs, uses zettelkasten for others
    ---@param title string|?
    ---@param path obsidian.Path|?
    ---@return string
    note_id_func = function(title, path)
      -- Check if we're in the daily notes directory
      local daily_notes_dir = Obsidian.dir / Obsidian.opts.daily_notes.folder
      if path and daily_notes_dir == path then
        -- For daily notes, return the title as-is (already formatted as YYYY-MM-DD)
        return title or tostring(os.date("%Y-%m-%d"))
      end
      -- For regular notes, use zettelkasten format with title slug
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,

    -- Templates configuration
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        meetingName = function()
          -- Return the cached value that was set in note_id_func
          return vim.g.obsidian_meeting_name or ""
        end,
      },
      customizations = {
        meeting = {
          notes_subdir = "notes/meetings",
          note_id_func = function(title, path)
            -- Generate filename as: YYYY-MM-DD-meeting-name
            local date = os.date("%Y-%m-%d")
            -- Prompt for meeting name HERE (before filename is generated)
            local meeting_name = vim.fn.input("Enter meeting name: ")
            -- Store it globally so the template substitution can use it
            vim.g.obsidian_meeting_name = meeting_name
            if meeting_name and meeting_name ~= "" then
              local slug = meeting_name:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
              return date .. "-" .. slug
            end
            return date .. "-meeting"
          end,
        },
      },
    },

    -- Follow URLs on Linux
    follow_url_func = function(url)
      vim.fn.jobstart({ "xdg-open", url })
    end,

    -- Search settings - show most recently modified notes first
    search = {
      sort_by = "modified",
      sort_reversed = true,
      max_lines = 100,
    },
  },
  keys = {
    {
      "<leader>o",
      "",
      desc = "Obsidian",
    },
    {
      "<leader>om",
      "<cmd>Obsidian new_from_template meeting<cr>",
      desc = "Obsidian: meeting template",
    },
    {
      "<leader>od",
      "<cmd>Obsidian dailies -20 8<cr>",
      desc = "Obsidian: dailies",
    },
    {
      "<leader>oy",
      "<cmd>Obsidian yesterday<cr>",
      desc = "Obsidian: dailies (yesterday)",
    },
    {
      "<leader>ot",
      "<cmd>Obsidian today<cr>",
      desc = "Obsidian: dailies (today)",
    },
    {
      "<leader>ow",
      "<cmd>Obsidian tomorrow<cr>",
      desc = "Obsidian: dailies (tomorrow)",
    },
  },
}
