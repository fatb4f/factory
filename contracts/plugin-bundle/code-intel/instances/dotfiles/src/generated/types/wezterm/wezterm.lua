---@meta

---@class WeztermAction: table

---@class WeztermPane
---@field get_current_working_dir fun(self: WeztermPane): string|nil
---@field send_text fun(self: WeztermPane, text: string)

---@class WeztermWindow
---@field active_pane fun(self: WeztermWindow): WeztermPane
---@field set_right_status fun(self: WeztermWindow, status: string)
---@field toast_notification fun(self: WeztermWindow, title: string, message: string, url?: string, timeout_ms?: integer)

---@class WeztermMuxWindow
---@field spawn_tab fun(self: WeztermMuxWindow, opts?: table): WeztermPane

---@class WeztermModule
---@field action fun(action: table): WeztermAction
---@field action_callback fun(callback: fun(window: WeztermWindow, pane: WeztermPane)): WeztermAction
---@field config_builder fun(): WeztermConfig
---@field font fun(name: string, opts?: table): table
---@field format fun(items: table[]): string
---@field log_error fun(...: any)
---@field log_info fun(...: any)
---@field mux table
---@field on fun(event: string, callback: function)

local wezterm = {}

return wezterm
