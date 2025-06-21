from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.backend.wayland import InputConfig
from libqtile.widget import backlight

mod = "mod4"
terminal = guess_terminal()

# Color scheme (Nord)

# Polar Night
nord0 = '2e3440'
nord1 = '3b4252'
nord2 = '434c5e'
nord3 = '4c566a'

# Snow Storm
nord4 = 'd8dee9'
nord5 = 'e5e9f0'
nord6 = 'eceff4'

# Frost
nord7 = '8fbcbb'
nord8 = '88c0d0'
nord9 = '81a1c1'
nord10 = '5e81ac'

# Aurora
nord11 = 'bf616a'
nord12 = 'd08770'
nord13 = 'ebcb8b'
nord14 = 'a3be8c'
nord15 = 'b48ead'

@lazy.function
def rename_current_group(qtile):
    prompt = qtile.widgets_map['prompt']

    print('got here')

    rename_group = lambda label: qtile.current_group.set_label(label if label.strip() != '' else None)
    prompt.start_input('New group label: ', rename_group)

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn("firefox"), desc="Launch browser"),
    Key([mod], "e", lazy.spawn("nautilus"), desc="Launch file explorer"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    # Brightness control.
    Key([], "XF86MonBrightnessDown", lazy.widget['backlight'].change_backlight(backlight.ChangeDirection.DOWN), desc="Decrease screen brightness"),
    Key([], "XF86MonBrightnessUp", lazy.widget['backlight'].change_backlight(backlight.ChangeDirection.UP), desc="Increase screen brightness"),

    # Volume control.
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Toggle mute of output audio"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"), desc="Decrease output volume"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"), desc="Increase output volume"),
    Key([], "XF86AudioMicMute", lazy.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), desc="Toggle mute of microphone"),

    # Rename groups using , (cfr. tmux).
    Key([mod], "comma", rename_current_group, desc="Rename current group"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "1234567890"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(toggle=True),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layout_defaults = dict(
    border_normal = nord0,
    border_normal_stack = nord0,
    border_focus = nord10,
    border_focus_stack = nord10,
    border_on_single = True,
    border_width = 4,
)

layouts = [
    layout.MonadTall(**layout_defaults),
    layout.Columns(**layout_defaults),
    layout.Max(**layout_defaults),
]

widget_defaults = dict(
    font="sans",
    fontsize=16,
    foreground=nord6,
    padding=5,
)
extension_defaults = widget_defaults.copy()

sep = widget.Sep(padding=10, size_percent=60)

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Spacer(length=4),
                widget.CurrentLayoutIcon(scale=0.6),
                sep,
                widget.GroupBox(
                    highlight_method = 'line',

                    highlight_color = nord1,                # Background of current group
                    block_highlight_text_color = nord6,     # Foreground of current group
                    this_current_screen_border = nord6,     # Color of the underline for current group
                    this_screen_border = nord6,             # Color of the underline for other screens

                    active = nord6,                         # Foreground of non-current, but used group
                    inactive = nord6,                       # Foreground of non-current, and unused group

                    hide_unused = True,
                ),
                sep,
                widget.Prompt(),
                widget.Spacer(),
                widget.Clock(
                    format="%a, %d %b %Y, %H:%M",
                    fmt = '{}',
                    mouse_callbacks = {
                        'Button1': lazy.spawn('foot bash -c "cal -y && read"'),
                    }
                ),
                widget.Spacer(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                # Systray is incompatible with Wayland, so use StatusNotifier instead.
                widget.StatusNotifier(),
                sep,
                widget.PulseVolume(
                    fmt = '  {}',
                    volume_app = 'pavucontrol',
                ),
                sep,
                widget.Wlan(
                    format = '{essid} {quality}/70',
                    fmt = '  {}',
                    interface = 'wlp58s0',
                    mouse_callbacks = {
                        'Button1': lazy.spawn('foot nmtui')
                    }
                ),
                widget.Bluetooth(
                    default_text = '󰂯 {num_connected_devices}',
                    mouse_callbacks = {
                        'Button1': lazy.spawn('foot bluetui')
                    }
                ),
                sep,
                widget.Backlight(
                    backlight_name = 'intel_backlight',
                    change_command = 'brightnessctl set {0}%',
                    min_brightness = 5,
                    fmt = '󰃠 {}',
                ),
                widget.Battery(
                    format = '{char} {percent:2.0%} ({hour:d}:{min:02d})',
                    charge_char = '󰂄',
                    discharge_char = '󰂍',
                    empty_char = '󰁺',
                    unknown_char = '󰂑',
                    full_short_text = '󰁹  Full',
                ),
                sep,
                widget.CheckUpdates(
                    display_format='{updates}',
                    no_update_string='0',
                    fmt = '󰚰 {}',
                ),
                sep,
                widget.QuickExit(
                    default_text = '󰐥',
                    countdown_format = '[{}]'
                ),
                widget.Spacer(length=4),
            ],
            36,
            background=nord0,
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
        wallpaper='~/.dotfiles/qtile/wallpaper.jpg',
        wallpaper_mode='stretch'
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = {
    'type:touchpad': InputConfig(tap=True, natural_scroll=True),
    'type:keyboard': InputConfig(kb_layout='us', kb_variant='altgr-intl')
}

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
