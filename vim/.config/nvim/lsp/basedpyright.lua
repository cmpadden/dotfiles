return {
    settings = {
        -- Organize imports functionality provided by `ruff`
        disableOrganizeImports = true,

        analysis = {

            -- Offer completions from the environment that, if accepted, simultaneously add an import
            -- statement in the current file.
            autoImportCompletions = true,

            -- Add "user symbols" from across your workspace to the autocompletion/autoimport list. These are
            -- symbols defined in your workspace (as opposed to in third-party
            -- libraries). The default behavior of Pylance is _not_ to show these,
            -- but the situation is somewhat confusing because it often shows them
            -- anyway-- that's because, when a symbol is defined in an already open
            -- file, it will be shown.
            -- See: https://github.com/microsoft/pylance-release/issues/3648
            autoImportUserSymbols = true,

            -- pylance copy
            autoFormatStrings = false,

            -- Search in common subdirectories like "src" for source files. This means you can put "foo"
            -- on pyright's path and put foo's packages in "foo/src", and pyright will find them.
            autoSearchPaths = true,

            -- Don't add parentheses when accepting a function/method completion.
            completeFunctionParens = false,

            -- The server continually analyzes some set of files in the background for issues. "workspace" mode will
            -- immediately start analyzing ALL project files-- tiis is a performance killer for large
            -- repos. "openFilesOnly" only looks at what's currently open in the editor.
            diagnosticMode = "openFilesOnly",

            -- Special handling for pytest. Not sure what it does.
            enablePytestSupport = true,

            -- Allow jumping to definition on string literals that represent module names.
            goToDefinitionInStringLiteral = true,

            -- Index code in your environment (both project files and third-party libraries). This is a
            -- major performance improvements for operations like rename or find_references.
            indexing = true,

            -- Shows inferred type as virtual text for unannotated functions and variables, including
            -- pytest fixtures.
            inlayHints = {
                variableTypes = false,
                functionReturnTypes = false,
                pytestParameters = true,
                callArgumentNames = false,
                genericTypes = false,
            },

            -- Set to "Trace" when debugging. This will cause many more messages to
            -- be logged to Neovim from the server (i.e. more `window/logMessage`
            -- requests are sent). Leave in "Info" for normal use.
            logLevel = "Info",

            -- Basic means it will not flag untyped stuff. Strict requires everything to be typed.
            typeCheckingMode = "basic",

            -- This is a poorly named option. It only affects how pyright deals with untyped (no py.typed)
            -- libraries. By default, no type information from library source is extracted (stubs will be
            -- used if present). With this setting, pyright will do its best to extract typing info from the
            -- source. The setting has no effect on typed libraries, which are always scanned.
            useLibraryCodeForTypes = false,

            -- -1 means no limit.
            userFileIndexingLimit = -1,

            reportExplicitAny = false,
        },
    },
}
