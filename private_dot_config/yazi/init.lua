-- ╭─────────────────────────────────────────────────────────╮
-- │                  Yazi Initialization                    │
-- ╰─────────────────────────────────────────────────────────╯

-- ═══════════════════════════════════════════════════════════
--  UI Enhancements
-- ═══════════════════════════════════════════════════════════

-- Integrate Starship prompt at bottom
require("starship"):setup()

-- Enable full border display
require("full-border"):setup()

-- Show repository status beside each file, after the normal linemode.
require("git"):setup({ order = 1500 })

-- ═══════════════════════════════════════════════════════════
--  Jump to Visible Files
-- ═══════════════════════════════════════════════════════════
require("easyjump"):setup()
