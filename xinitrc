# ENAble locking after 5 minutes
xautolock -time 5 -locker i3lock &

# set external monitor
# xrandr --auto --output VGA1 --mode 1920x1080 && xrandr --output LVDS1 --off &

# set background using feh
# sh ~/.fehbg &

# reloads xresources configuration
xrdb -merge /home/thrax/.Xresources &

# disable touch screen (finger)
# xinput disable "Wacom ISDv4 E6 Finger touch &

# launch i3
exec i3
