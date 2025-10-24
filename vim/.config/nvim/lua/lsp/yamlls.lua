return {
    settings = {
        yaml = {
            -- TODO - dynamically check if schemas are present
            schemas = {
                [".vscode/schema.json"] = "**/*.y*ml",
            },
        },
    },
}
