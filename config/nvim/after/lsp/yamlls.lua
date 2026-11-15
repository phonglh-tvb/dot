return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" }, -- dùng SchemaStore.nvim thay vì tự fetch
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}
