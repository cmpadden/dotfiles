# set external monitor
# xrandr --auto --output VGA1 --mode 1920x1080 && xrandr --output LVDS1 --off &

# set background using feh
sh ~/.fehbg &

# reloads xresources configuration
xrdb ~/.Xresources &

# allows the use of terminus font
xset +fp /usr/share/fonts/local &
xset fp rehash &

# autostart nm-applet
exec nm-applet &

#disables the system beep
xset -b

# disable touch screen (finger)
xinput disable "Wacom ISDv4 E6 Finger touch"

# starts dropbox after 10s
(sleep 10 && exec dropboxd ) &

exec i3
