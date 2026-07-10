return {
  {
    name = "activitywatch-local",
    dir = vim.fn.stdpath("config"),
    event = { "BufEnter", "BufWritePost", "CursorHold", "FocusGained" },
    config = function()
      local hostname = vim.uv.os_gethostname()
      local bucket = "aw-watcher-neovim_" .. hostname
      local base_url = "http://127.0.0.1:5600/api/0/buckets/" .. bucket
      local pulsetime = 30
      local last_heartbeat = 0

      local function post(url, body)
        vim.system({ "curl", "-fsS", "-X", "POST", url, "-H", "content-type: application/json", "--data-raw", vim.json.encode(body) }, { text = true })
      end

      local function project_name()
        local cwd = vim.uv.cwd() or vim.fn.getcwd()
        return vim.fn.fnamemodify(cwd, ":t")
      end

      local function file_name()
        local name = vim.api.nvim_buf_get_name(0)
        return name ~= "" and name or (vim.bo.filetype ~= "" and vim.bo.filetype or "neovim")
      end

      local function title_for(file, project)
        local file_title = vim.fn.fnamemodify(file, ":t")
        if file_title == "" then
          file_title = "neovim"
        end
        return file_title .. " - " .. project
      end

      local function heartbeat()
        local now = os.time()
        if now - last_heartbeat < 8 then
          return
        end
        last_heartbeat = now

        local file = file_name()
        local project = project_name()
        post(base_url .. "/heartbeat?pulsetime=" .. pulsetime, {
          timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
          duration = 0,
          data = {
            app = "neovim",
            title = title_for(file, project),
            file = file,
            project = project,
            language = vim.bo.filetype,
          },
        })
      end

      post(base_url, {
        hostname = hostname,
        client = "neovim-local-watcher",
        type = "app.editor.activity",
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "FocusGained" }, {
        group = vim.api.nvim_create_augroup("activitywatch-local", { clear = true }),
        callback = heartbeat,
      })
      vim.api.nvim_create_user_command("AWHeartbeat", heartbeat, { desc = "Send ActivityWatch heartbeat" })
    end,
  },
}
