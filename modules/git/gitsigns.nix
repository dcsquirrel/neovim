{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.git;
in {
  options.vim.git = {
    enable = mkEnableOption "Git support";

    gitsigns = {
      enable = mkEnableOption "gitsigns";

      codeActions = mkEnableOption "gitsigns codeactions through null-ls";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.gitsigns.enable (mkMerge [
      {
        vim.startPlugins = ["gitsigns-nvim"];

        vim.luaConfigRC.gitsigns = nvim.dag.entryAnywhere ''
          require('gitsigns').setup {
            watch_gitdir = {
            interval = 1000,
            follow_files = true
            },
            attach_to_untracked = true,
            current_line_blame = false,
            current_line_blame_opts = {
              virt_text = true,
              virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
              delay = 1000,
              ignore_whitespace = false,
            },
            current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 1000, -- Disable if file is longer than this (in lines)
            preview_config = {
              -- Options passed to nvim_open_win
              border = 'single',
              style = 'minimal',
              relative = 'cursor',
              row = 0,
              col = 1
            },
            yadm = {
              enable = false
            },
            keymaps = {
              noremap = true,

              ['n <leader>gn'] = { expr = true, "&diff ? \'\' : '<cmd>Gitsigns next_hunk<CR>'"},
              ['n <leader>gp'] = { expr = true, "&diff ? \'\' : '<cmd>Gitsigns prev_hunk<CR>'"},

              ['n <leader>gs'] = '<cmd>Gitsigns stage_hunk<CR>',
              ['v <leader>gs'] = ':Gitsigns stage_hunk<CR>',
              ['n <leader>gu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
              ['n <leader>gr'] = '<cmd>Gitsigns reset_hunk<CR>',
              ['v <leader>gr'] = ':Gitsigns reset_hunk<CR>',
              ['n <leader>gR'] = '<cmd>Gitsigns reset_buffer<CR>',
              ['n <leader>gp'] = '<cmd>Gitsigns preview_hunk<CR>',
              ['n <leader>gb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
              ['n <leader>gl'] = '<cmd>Gitsigns toggle_current_line_blame<CR>',
              ['n <leader>gS'] = '<cmd>Gitsigns stage_buffer<CR>',
              ['n <leader>gU'] = '<cmd>Gitsigns reset_buffer_index<CR>',
              ['n <leader>gts'] = ':Gitsigns toggle_signs<CR>',
              ['n <leader>gtn'] = ':Gitsigns toggle_numhl<CR>',
              ['n <leader>gtl'] = ':Gitsigns toggle_linehl<CR>',
              ['n <leader>gtw'] = ':Gitsigns toggle_word_diff<CR>',

              -- Text objects
              ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
              ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>'
            },
          }
        '';
      }

      (mkIf cfg.gitsigns.codeActions {
        vim.lsp.null-ls.enable = true;
        vim.lsp.null-ls.sources.gitsigns-ca = ''
          table.insert(
            ls_sources,
            null_ls.builtins.code_actions.gitsigns
          )
        '';
      })
    ]))
  ]);
}
