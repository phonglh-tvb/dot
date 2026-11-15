-- vimtex lo việc build/view, texlab chỉ làm completion, diagnostics, format
return {
  settings = {
    texlab = {
      build = { onSave = false },
      chktex = { onOpenAndSave = true },
    },
  },
}
