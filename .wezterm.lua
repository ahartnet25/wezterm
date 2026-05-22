local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-------------------------------------------------
-- Shortcut reference
-------------------------------------------------
--
-- CTRL + T
--   Open a new WSL tab
--
-- CTRL + TAB
--   Move to next tab
--
-- CTRL + SHIFT + TAB
--   Move to previous tab
--
-- CTRL + SHIFT + L
--   Open launcher menu
--   Includes PowerShell 7, Windows PowerShell, CMD, and SSH
--
-- CTRL + SHIFT + R
--   Rename the current tab
--
-- CTRL + C
--   Copy selected text
--   If no text is selected, sends CTRL+C to the shell
--
-- CTRL + V
--   Paste from clipboard
--
-- CTRL + F
--   Search current terminal scrollback
--
-- Notes:
--   No close-tab shortcut
--   No pane split shortcuts
--   No fullscreen shortcut
--   No command palette shortcut
--   No Codex shortcut
--   No PowerShell direct shortcut
--

-------------------------------------------------
-- WSL readability note
-------------------------------------------------
--
-- If folders under /mnt/c show with an unreadable highlighted background,
-- fix it inside WSL by adding this to ~/.bashrc:
--
--   export LS_COLORS="$LS_COLORS:di=01;36:ow=01;36:tw=01;36:st=01;36"
--
-- Then reload WSL shell settings with:
--
--   source ~/.bashrc
--
-- This is a Linux ls/LS_COLORS issue, not a WezTerm color-scheme issue.
--

------------------------------------------------
-- Appearance
-------------------------------------------------

-- Modern dark theme with custom ANSI overrides below.
-- The ANSI overrides are what improve WSL folder/readability contrast.
config.color_scheme = 'Catppuccin Mocha'

config.font = wezterm.font_with_fallback({
  {
    family = 'Cascadia Code',
    harfbuzz_features = {
      'calt=1',
      'clig=1',
      'liga=1',
    },
  },
  'Cascadia Mono',
  'Consolas',
})

config.font_size = 11

-- Transparency restored.
config.window_background_opacity = 0.94
config.text_background_opacity = 1.0

-- Avoid gradient because it can make folder colors inconsistent.
config.window_background_gradient = nil

-- Higher-contrast ANSI colors.
-- WSL folders often render as ANSI blue; this makes that blue brighter.
config.colors = {
  ansi = {
    '#45475a', -- black
    '#f38ba8', -- red
    '#a6e3a1', -- green
    '#f9e2af', -- yellow
    '#89dceb', -- blue / common directory color
    '#cba6f7', -- magenta
    '#94e2d5', -- cyan
    '#bac2de', -- white
  },

  brights = {
    '#585b70', -- bright black
    '#f38ba8', -- bright red
    '#a6e3a1', -- bright green
    '#f9e2af', -- bright yellow
    '#74c7ec', -- bright blue
    '#cba6f7', -- bright magenta
    '#94e2d5', -- bright cyan
    '#ffffff', -- bright white
  },

  selection_fg = '#11111b',
  selection_bg = '#f9e2af',

  cursor_bg = '#f5e0dc',
  cursor_fg = '#11111b',
  cursor_border = '#f5e0dc',
}

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 6,
}

-- Very subtle dimming so inactive panes stay readable.
config.inactive_pane_hsb = {
  saturation = 0.95,
  brightness = 0.9,
}

-------------------------------------------------
-- Startup
-------------------------------------------------

-- Default to WSL home directory.
config.default_prog = {
  'wsl.exe',
  '--cd',
  '~',
}

-- Start maximized.
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-------------------------------------------------
-- Launcher menu
-------------------------------------------------

config.launch_menu = {
  {
    label = 'PowerShell 7',
    args = { 'pwsh.exe', '-NoLogo' },
  },
  {
    label = 'Windows PowerShell',
    args = { 'powershell.exe', '-NoLogo' },
  },
  {
    label = 'Command Prompt',
    args = { 'cmd.exe' },
  },
  {
    label = 'SSH',
    args = {
      'wsl.exe',
      '--cd',
      '~',
      '--exec',
      'bash',
      '-lc',
      'read -e -p "ssh " target; ssh "$target"',
    },
  },
}

-------------------------------------------------
-- General behavior
-------------------------------------------------

config.audible_bell = 'Disabled'
config.check_for_updates = true
config.default_cursor_style = 'BlinkingBar'
config.adjust_window_size_when_changing_font_size = false
config.hide_mouse_cursor_when_typing = true
config.scrollback_lines = 20000

-- Safer close behavior.
config.window_close_confirmation = 'AlwaysPrompt'

-------------------------------------------------
-- Keybindings
-------------------------------------------------

config.keys = {
  -------------------------------------------------
  -- Launcher
  -------------------------------------------------

  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ShowLauncher,
  },

  -------------------------------------------------
  -- Tabs
  -------------------------------------------------

  {
    key = 't',
    mods = 'CTRL',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  {
    key = 'Tab',
    mods = 'CTRL',
    action = wezterm.action.ActivateTabRelative(1),
  },

  {
    key = 'Tab',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },

  {
    key = 'R',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -------------------------------------------------
  -- Windows-style copy / paste / search
  -------------------------------------------------

  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local selection = window:get_selection_text_for_pane(pane)

      if selection and selection ~= '' then
        window:perform_action(wezterm.action.CopyTo 'Clipboard', pane)
      else
        window:perform_action(wezterm.action.SendKey {
          key = 'C',
          mods = 'CTRL',
        }, pane)
      end
    end),
  },

  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
  },

  {
    key = 'f',
    mods = 'CTRL',
    action = wezterm.action.Search 'CurrentSelectionOrEmptyString',
  },
}

-------------------------------------------------
-- Mouse behavior
-------------------------------------------------

-- Keep mouse behavior Windows-like.
-- No right-click paste.
-- No middle-click paste.
config.mouse_bindings = {}

-------------------------------------------------
-- Tab title formatting
-------------------------------------------------

wezterm.on('format-tab-title', function(tab)
  local title = tab.tab_title

  if title == nil or title == '' then
    title = tab.active_pane.title or ''
  end

  local lower_title = string.lower(title)

  if lower_title:find('pwsh') then
    title = 'PowerShell'
  elseif lower_title:find('powershell') then
    title = 'WinPS'
  elseif lower_title:find('cmd.exe') then
    title = 'CMD'
  elseif lower_title:find('ssh') then
    title = 'SSH'
  elseif lower_title:find('wsl') or lower_title == '' then
    title = 'WSL'
  end

  return {
    { Text = '  ' .. title .. '  ' },
  }
end)

return config