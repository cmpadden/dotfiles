-- Clipboard files -> original paths; clipboard pixels -> persistent temporary file;
-- otherwise use Neovim's normal system-clipboard paste. Requires Neovim 0.10+.
local M = {}
local uv = vim.uv or vim.loop
local timeout = 5000

-- AppKit is available through the built-in JXA bridge; no pngpaste/Node dependency.
-- Like Pi, prefer Finder file URLs over image representations (including thumbnails).
local macos_script = [[
ObjC.import('AppKit');
function run(argv) {
    const pb = $.NSPasteboard.generalPasteboard;
    const urls = pb.readObjectsForClassesOptions(
        $.NSArray.arrayWithObject($.NSURL),
        $.NSDictionary.dictionaryWithObjectForKey(true, $.NSPasteboardURLReadingFileURLsOnlyKey)
    );
    const paths = [];
    if (!urls.isNil()) {
        for (let i = 0; i < urls.count; i++) paths.push(ObjC.unwrap(urls.objectAtIndex(i).path));
    }
    if (paths.length) return JSON.stringify({paths: paths});
    const types = $.NSArray.arrayWithArray(['public.png', 'public.tiff']);
    if (pb.availableTypeFromArray(types).isNil()) return '{}';
    let png = pb.dataForType($.NSPasteboardTypePNG);
    if (png.isNil()) {
        const image = $.NSImage.alloc.initWithPasteboard(pb);
        if (image.isNil()) throw new Error('Could not decode clipboard image');
        const tiff = image.TIFFRepresentation;
        if (tiff.isNil()) throw new Error('Could not decode clipboard TIFF');
        const bitmap = $.NSBitmapImageRep.imageRepWithData(tiff);
        if (bitmap.isNil()) throw new Error('Could not decode clipboard bitmap');
        png = bitmap.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $({}));
    }
    if (png.isNil() || !png.length || !png.writeToFileAtomically(argv[0], true)) {
        throw new Error('Could not write clipboard image');
    }
    return JSON.stringify({image: true});
}
]]

local extensions = {
    ["image/png"] = "png",
    ["image/jpeg"] = "jpg",
    ["image/webp"] = "webp",
    ["image/gif"] = "gif",
}
local preferred_types = { "image/png", "image/jpeg", "image/webp", "image/gif" }

local function run(argv, list)
    local result = vim.system(argv, { text = false }):wait(list and 1000 or timeout)
    if result.code ~= 0 then
        error(
            (result.stderr or ""):match("%S") and result.stderr
                or "Clipboard command failed or timed out"
        )
    end
    return result.stdout or ""
end

local function temporary_directory()
    -- Do not use tempname(): Neovim deletes its temp directory on exit, invalidating
    -- paths pasted into an external editor or sent to an agent after closing Neovim.
    local dir, err = uv.fs_mkdtemp(uv.os_tmpdir() .. "/nvim-image-paste-XXXXXX")
    assert(dir, err)
    return dir
end

local function save_image(bytes, extension)
    local dir = temporary_directory() -- mkdtemp creates a private (0700) directory.
    local path = dir .. "/clipboard." .. extension
    local ok, err = pcall(function()
        local fd, open_err = uv.fs_open(path, "wx", 384) -- 0600
        assert(fd, open_err)
        local written, write_err = uv.fs_write(fd, bytes, 0)
        uv.fs_close(fd)
        assert(written == #bytes, write_err or "Incomplete image write")
    end)
    if not ok then
        vim.fn.delete(dir, "rf")
        error(err)
    end
    return path
end

local function macos_clipboard()
    local dir = temporary_directory()
    local path = dir .. "/clipboard.png"
    local ok, result = pcall(function()
        local data =
            vim.json.decode(run({ "osascript", "-l", "JavaScript", "-e", macos_script, path }))
        if data.paths and #data.paths > 0 then
            for _, file in ipairs(data.paths) do
                assert(not file:find("%c"), "Clipboard file path contains control characters")
            end
            return table.concat(data.paths, "\n")
        end
        if data.image then
            local stat = uv.fs_stat(path)
            assert(stat and stat.size > 0, "Clipboard image is empty")
            assert(uv.fs_chmod(path, 384))
            return path
        end
    end)
    if not ok or result ~= path then
        vim.fn.delete(dir, "rf")
    end
    if not ok then
        error(result)
    end
    return result
end

local function linux_image(list_command, read_command)
    local types = vim.split(run(list_command, true), "\n", { trimempty = true })
    for _, preferred in ipairs(preferred_types) do
        for _, raw_type in ipairs(types) do
            raw_type = vim.trim(raw_type)
            local base = vim.trim(raw_type:match("^[^;]+") or ""):lower()
            if base == preferred then
                local bytes = run(read_command(raw_type))
                if #bytes > 0 then
                    return save_image(bytes, extensions[base])
                end
                return nil
            end
        end
    end
end

---Read a file path/image from the clipboard; nil means use the text clipboard.
---Returns text, error. Does not change registers or the current buffer.
function M.read()
    local ok, result = pcall(function()
        if vim.fn.has("macunix") == 1 then
            return macos_clipboard()
        end
        if vim.fn.has("unix") ~= 1 then
            return nil
        end
        if vim.env.WAYLAND_DISPLAY or vim.env.XDG_SESSION_TYPE == "wayland" then
            if vim.fn.executable("wl-paste") == 1 then
                -- Only fall back to X11 on a backend failure, never on an empty
                -- Wayland clipboard (which could otherwise paste stale X11 pixels).
                local success, image = pcall(
                    linux_image,
                    { "wl-paste", "--list-types" },
                    function(mime)
                        return { "wl-paste", "--type", mime, "--no-newline" }
                    end
                )
                if success then
                    return image
                end
                if not vim.env.DISPLAY or vim.fn.executable("xclip") ~= 1 then
                    error(image)
                end
            end
        end
        if vim.env.DISPLAY and vim.fn.executable("xclip") == 1 then
            return linux_image(
                { "xclip", "-selection", "clipboard", "-t", "TARGETS", "-o" },
                function(mime)
                    return { "xclip", "-selection", "clipboard", "-t", mime, "-o" }
                end
            )
        end
    end)
    if not ok then
        return nil, tostring(result)
    end
    return result
end

---Paste clipboard files/images, falling back to regular clipboard text.
---@param opts? {before?: boolean}
function M.paste(opts)
    opts = opts or {}
    if not vim.bo.modifiable then
        vim.notify("nvim-image-paste: buffer is not modifiable", vim.log.levels.WARN)
        return
    end
    local text, err = M.read()
    if err then
        vim.notify("nvim-image-paste: " .. err, vim.log.levels.WARN)
    end
    local insert = vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
    if insert then
        local lines = text and vim.split(text, "\n", { plain = true })
            or vim.fn.getreg("+", 1, true)
        vim.api.nvim_put(lines, "c", false, true)
    elseif text then
        -- Use a real put so normal/visual p/P retain their usual placement and
        -- selection semantics. Restore scratch and unnamed registers afterwards.
        local scratch, unnamed = vim.fn.getreginfo("z"), vim.fn.getreginfo('"')
        vim.fn.setreg("z", text, "v")
        local success, put_err = pcall(vim.cmd.normal, {
            args = { '"z' .. (opts.before and "P" or "p") },
            bang = true,
        })
        vim.fn.setreg("z", scratch)
        vim.fn.setreg('"', unnamed)
        if not success then
            vim.notify("nvim-image-paste: " .. tostring(put_err), vim.log.levels.ERROR)
        end
    else
        vim.cmd.normal({ args = { '"+' .. (opts.before and "P" or "p") }, bang = true })
    end
end

---Register commands and optional clipboard mappings. Leaves normal p/P and Ctrl-V alone.
---@param opts? {mappings?: boolean, timeout?: integer}
function M.setup(opts)
    opts = opts or {}
    timeout = opts.timeout or 5000
    vim.api.nvim_create_user_command("ImagePaste", function()
        M.paste()
    end, { desc = "Paste clipboard image/file path or text", force = true })
    if opts.mappings ~= false then
        vim.keymap.set("i", "<C-v>", M.paste, { desc = "Paste clipboard image/file or text" })
    end
end

return M
