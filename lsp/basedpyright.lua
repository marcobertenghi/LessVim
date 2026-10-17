-- Extends the basedpyright config shipped with nvim-lspconfig.
return {
  settings = {
    basedpyright = {
      analysis = {
        -- basedpyright's default ("recommended") is extremely strict;
        -- "standard" matches regular pyright. Bump to "strict" if you like pain.
        typeCheckingMode = 'standard',
      },
    },
  },
}
