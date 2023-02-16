[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
xmodmap ~/.config/.Xmodmap
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY


./.screenlayout/default.sh &
xcompmgr -c &
# Set background image with feh
feh --bg-scale ~/.config/backgrounds/dojo.jpg &

rm  /tmp/xmonad

exec my-xmonad

