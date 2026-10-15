-- Run from the repository root:
-- nvim --headless -u NONE -i NONE -l vim/.config/nvim/tests/nvim-image-paste.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/vim/.config/nvim")
local image_copy = require("nvim-image-paste")
local uv = vim.uv
local original = {
    system = vim.system,
    has = vim.fn.has,
    executable = vim.fn.executable,
    tmpdir = uv.os_tmpdir,
    read = image_copy.read,
    notify = vim.notify,
    wayland = vim.env.WAYLAND_DISPLAY,
    session = vim.env.XDG_SESSION_TYPE,
    display = vim.env.DISPLAY,
}
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
uv.os_tmpdir = function()
    return root
end
local count = 0
local function equal(expected, actual)
    assert(vim.deep_equal(expected, actual), vim.inspect({ expected = expected, actual = actual }))
end
local function test(name, callback)
    vim.system = original.system
    vim.fn.has = original.has
    vim.fn.executable = original.executable
    image_copy.read = original.read
    vim.notify = original.notify
    vim.env.WAYLAND_DISPLAY = nil
    vim.env.XDG_SESSION_TYPE = nil
    vim.env.DISPLAY = nil
    vim.cmd("enew!")
    vim.cmd.normal({ args = { "\027" }, bang = true })
    callback()
    count = count + 1
    print("ok - " .. name)
end
local function linux(responses)
    vim.fn.has = function(feature)
        return feature == "unix" and 1 or 0
    end
    vim.fn.executable = function()
        return 1
    end
    vim.env.WAYLAND_DISPLAY = "test-wayland"
    vim.env.DISPLAY = ":test"
    local index = 0
    vim.system = function(argv, opts)
        index = index + 1
        local response = assert(responses[index], "Unexpected command: " .. vim.inspect(argv))
        equal(response.argv, argv)
        equal(false, opts.text)
        return {
            wait = function(_, ms)
                equal(response.list and 1000 or 5000, ms)
                return {
                    code = response.code or 0,
                    stdout = response.stdout,
                    stderr = "test failure",
                }
            end,
        }
    end
    return function()
        equal(#responses, index)
    end
end
local png = "\137PNG\r\n\026\n\0binary\255\r\n"
local function clipboard_image()
    image_copy.read = function()
        return "/tmp/test image.png"
    end
end

local ok, err = xpcall(function()
    test("Wayland selects PNG, preserves binary bytes, and saves privately", function()
        local done = linux({
            {
                argv = { "wl-paste", "--list-types" },
                list = true,
                stdout = "image/jpeg\nimage/png\n",
            },
            { argv = { "wl-paste", "--type", "image/png", "--no-newline" }, stdout = png },
        })
        local path, read_err = image_copy.read()
        assert(path, read_err)
        local fd = assert(uv.fs_open(path, "r", 0))
        equal(png, uv.fs_read(fd, #png, 0))
        uv.fs_close(fd)
        equal(384, uv.fs_stat(path).mode % 512)
        equal(448, uv.fs_stat(vim.fs.dirname(path)).mode % 512)
        done()
    end)
    test("empty Wayland clipboard never reads stale X11 contents", function()
        local done = linux({
            { argv = { "wl-paste", "--list-types" }, list = true, stdout = "text/plain\n" },
        })
        equal(nil, image_copy.read())
        done()
    end)
    test("failed Wayland backend falls back to X11, preserving MIME parameters", function()
        local done = linux({
            { argv = { "wl-paste", "--list-types" }, list = true, code = 1 },
            {
                argv = { "xclip", "-selection", "clipboard", "-t", "TARGETS", "-o" },
                list = true,
                stdout = "image/jpeg; foo=bar\n",
            },
            {
                argv = { "xclip", "-selection", "clipboard", "-t", "image/jpeg; foo=bar", "-o" },
                stdout = "jpeg bytes",
            },
        })
        local path, read_err = image_copy.read()
        assert(path, read_err)
        assert(path:match("%.jpg$"))
        done()
    end)
    test("backend failures return an error without leaving temp files", function()
        local done = linux({
            { argv = { "wl-paste", "--list-types" }, list = true, code = 124 },
        })
        vim.env.DISPLAY = nil
        local path, read_err = image_copy.read()
        equal(nil, path)
        assert(read_err:find("test failure", 1, true))
        done()
    end)
    test("normal image put preserves scratch and unnamed registers", function()
        clipboard_image()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "ab" })
        vim.fn.setreg("z", "scratch", "V")
        vim.fn.setreg('"', "unnamed", "v")
        local z, unnamed = vim.fn.getreginfo("z"), vim.fn.getreginfo('"')
        image_copy.paste()
        equal({ "a/tmp/test image.pngb" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
        equal(z, vim.fn.getreginfo("z"))
        equal(unnamed, vim.fn.getreginfo('"'))
    end)
    test("P inserts before the cursor", function()
        clipboard_image()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "ab" })
        image_copy.paste({ before = true })
        equal({ "/tmp/test image.pngab" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)
    test("visual image put replaces the selection", function()
        clipboard_image()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "abc" })
        vim.cmd.normal({ args = { "vl" }, bang = true })
        image_copy.paste()
        equal({ "/tmp/test image.pngc" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)
    test("text fallback keeps linewise clipboard semantics", function()
        vim.g.clipboard = {
            name = "test",
            copy = { ["+"] = function() end, ["*"] = function() end },
            paste = {
                ["+"] = function()
                    return { { "clipboard text" }, "V" }
                end,
                ["*"] = function()
                    return { { "clipboard text" }, "V" }
                end,
            },
        }
        image_copy.read = function()
            return nil
        end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "original" })
        image_copy.paste()
        equal({ "original", "clipboard text" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)
    test("insert-mode Ctrl-V inserts a path at the cursor", function()
        clipboard_image()
        image_copy.setup()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "ab" })
        local keys = vim.api.nvim_replace_termcodes("a<C-v><Esc>", true, false, true)
        vim.api.nvim_feedkeys(keys, "xt", false)
        equal({ "a/tmp/test image.pngb" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
        equal("", vim.fn.maparg("<C-v>", "n"))
        for _, mode in ipairs({ "n", "x" }) do
            equal("", vim.fn.maparg("<leader>p", mode))
            equal("", vim.fn.maparg("<leader>P", mode))
        end
    end)
    test("unmodifiable buffer does not read the clipboard", function()
        image_copy.read = function()
            error("Must not read")
        end
        vim.notify = function() end
        vim.bo.modifiable = false
        image_copy.paste()
        vim.bo.modifiable = true
    end)
    if original.has("macunix") == 1 then
        -- Exercise the real AppKit/JXA bridge against a PRIVATE pasteboard, never
        -- read or overwrite the user's system clipboard during these tests.
        local fixture_png =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg=="
        local fixtures = {
            empty = "",
            text = "pb.setStringForType('https://example.com/image.png', 'public.utf8-plain-text');",
            png = "pb.setDataForType(data, 'public.png');",
            tiff = "const image = $.NSImage.alloc.initWithData(data); pb.setDataForType(image.TIFFRepresentation, 'public.tiff');",
            files = "pb.writeObjects($.NSArray.arrayWithObject($.NSURL.fileURLWithPath('/tmp/original image.png'))); pb.setDataForType(data, 'public.png');",
        }
        for name, fixture in pairs(fixtures) do
            test("AppKit private pasteboard: " .. name, function()
                vim.system = function(argv, opts)
                    local replacement = "const pb = $.NSPasteboard.pasteboardWithUniqueName;\n"
                        .. "const data = $.NSData.alloc.initWithBase64EncodedStringOptions('"
                        .. fixture_png
                        .. "', 0);\n"
                        .. fixture
                    argv[5] = argv[5]:gsub(
                        "const pb = %$%.NSPasteboard%.generalPasteboard;",
                        function()
                            return replacement
                        end
                    )
                    return original.system(argv, opts)
                end
                local path, read_err = image_copy.read()
                assert(not read_err, read_err)
                if name == "empty" or name == "text" then
                    equal(nil, path)
                elseif name == "files" then
                    equal("/tmp/original image.png", path)
                else
                    assert(path and uv.fs_stat(path).size > 0)
                    equal(384, uv.fs_stat(path).mode % 512)
                end
            end)
        end
    end
end, debug.traceback)
vim.system = original.system
vim.fn.has = original.has
vim.fn.executable = original.executable
uv.os_tmpdir = original.tmpdir
vim.env.WAYLAND_DISPLAY = original.wayland
vim.env.XDG_SESSION_TYPE = original.session
vim.env.DISPLAY = original.display
vim.fn.delete(root, "rf")
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
end
print(string.format("Passed %d tests", count))
vim.cmd("qa!")
