-- Markdown / LaTeX / Typst
return {
  -- Markdown: render ngay trong buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      file_types = { "markdown" },
      completions = { lsp = { enabled = true } },
    },
  },

  -- Markdown: preview trên trình duyệt (hỗ trợ KaTeX, mermaid)
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    -- npm sửa yarn.lock làm plugin bị "local changes" -> Lazy không update được
    build = "cd app && npm install --no-package-lock && git checkout -- yarn.lock",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
    end,
  },

  -- LaTeX: compile (latexmk), viewer, text objects, TOC. Không lazy-load.
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      -- Skim cho forward/inverse search; chưa cài thì mở bằng viewer mặc định (Preview)
      if vim.uv.fs_stat "/Applications/Skim.app" then
        vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_view_skim_sync = 1
        vim.g.vimtex_view_skim_activate = 1
      else
        vim.g.vimtex_view_method = "general"
      end

      -- Engine Unicode để gõ tiếng Việt trực tiếp; đổi từng file bằng `% !TEX program = pdflatex`
      vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
      vim.g.vimtex_quickfix_open_on_warning = 0
    end,
  },

  -- Typst: live preview (dùng tinymist cài qua mason)
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
      dependencies_bin = { tinymist = "tinymist" },
    },
  },
}
