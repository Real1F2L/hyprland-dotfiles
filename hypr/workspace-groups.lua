local monitor_file = io.open(os.getenv("HOME") .. "/.config/1f2l/workspace-group-monitors", "r")
if not monitor_file then
    error("Could not read ~/.config/1f2l/workspace-group-monitors")
end

local monitors = {}
local monitor_set = {}
for line in monitor_file:lines() do
    local monitor = line:match("^%s*(.-)%s*$")
    if monitor ~= "" and not monitor:match("^#") then
        if not monitor:match("^[%w_.:-]+$") then
            monitor_file:close()
            error("Invalid monitor name in workspace-group-monitors: " .. monitor)
        end
        if monitor_set[monitor] then
            monitor_file:close()
            error("Duplicate monitor in workspace-group-monitors: " .. monitor)
        end
        monitor_set[monitor] = true
        table.insert(monitors, monitor)
    end
end
monitor_file:close()

if #monitors == 0 then
    error("No monitors configured in ~/.config/1f2l/workspace-group-monitors")
end

local group_count = 9
local monitor_count = #monitors
for group = 1, group_count do
    for monitor_index, monitor in ipairs(monitors) do
        local workspace = (group - 1) * monitor_count + monitor_index
        hl.workspace_rule({
            workspace = tostring(workspace),
            monitor = monitor,
            persistent = true,
        })
    end
end

local script = "~/.config/1f2l-dotfiles/Scripts/workspace-groups.sh"
for group = 1, group_count do
    local key = tostring(group)
    hl.bind("SUPER + " .. key, hl.dsp.exec_cmd(script .. " switch " .. key), {
        description = "Switch all monitors to workspace group " .. key,
    })
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.exec_cmd(script .. " move " .. key), {
        description = "Move window to workspace group " .. key,
    })
end
