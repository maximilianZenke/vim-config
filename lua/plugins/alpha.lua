-- https://github.com/nxtkofi/LightningNvim?tab=readme-ov-file#dashboard-images amazing tutorial! 
return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        _Gopts = {
            position = "center",
            hl = "Type",
            wrap = "overflow"
        }

        local function load_random_header()
            math.randomseed(os.time())
            local header_folder = vim.fn.stdpath("config") .. "/lua/plugins/header_img/"
            local files = vim.fn.globpath(header_folder, "*.lua", true, true)
            if #files == 0 then
                return nil
            end

            local random_file = files[math.random(#files)]
            local separator = package.config:sub(1, 1)
            local module_name = "plugins.header_img." .. random_file:match("([^" .. separator .. "]+)%.lua$")

            package.loaded[module_name] = nil

            local ok, module = pcall(require, module_name)
            if ok and module.header then
                return module.header
            else
                return nil
            end
        end

        local function change_header()
            local new_header = load_random_header()
            if new_header then
                dashboard.config.layout[2] = new_header
                vim.cmd("AlphaRedraw")
            else
                print("No images inside header_img folder.")
                dashboard.config.layout[2] = ""
            end
        end

        vim.api.nvim_create_user_command("ChangeHeader", function()
            change_header()
        end, {})

        local header = load_random_header()
        if header then
            dashboard.config.layout[2] = header
        else
            dashboard.config.layout[2] = ""
        end

        dashboard.section.buttons.val = {dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
                                         dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
                                         dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
                                         dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
                                         dashboard.button("c", "  Configuration", ":Telescope find_files cwd=" ..
            vim.fn.expand("$HOME") .. "/AppData/Local/nvim/lua/ <CR>"),
                                         dashboard.button("SPC t", "🖮  Practice typing with Typr ", ":Typr<CR>"),
                                         dashboard.button("w", "  Change header image", ":ChangeHeader<CR>"),
                                         dashboard.button("q", "  Quit Neovim", ":qa<CR>")}

        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyVimStarted",
            desc = "Add Alpha dashboard footer",
            once = true,
            callback = function()
                local stats = require("lazy").stats()
                local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
                dashboard.section.footer.val = {" ", " ", " ",
                                                " Loaded " .. stats.count .. " plugins  in " .. ms .. " ms "}
                dashboard.section.header.opts.hl = "DashboardFooter"
                pcall(vim.cmd.AlphaRedraw)
            end
        })

        dashboard.opts.opts.noautocmd = true
        alpha.setup(dashboard.opts)
    end
}
