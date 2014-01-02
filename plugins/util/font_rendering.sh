# Name: Improve font rendering
# Command: font_rendering

font_rendering() {
show_func "Improving font rendering"
if [[ "$(font_rendering_test)" = "Improved" && ! "$reinstall" = "yes" ]]; then
    show_status "Font rendering already improved"
else
    add_repo "rpmfusion-free.repo"
    add_repo "rpmfusion-nonfree.repo"
    install_pkg freetype-freeworld
fi
make_backup "/etc/fonts/local.conf"
cat <<EOF | tee /etc/fonts/local.conf > /dev/null 2>&1
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <match target="font">
  <edit name="autohint" mode="assign">
   <bool>true</bool>
  </edit>
  <edit name="hinting" mode="assign">
   <bool>true</bool>
  </edit>
  <edit mode="assign" name="hintstyle">
   <const>hintslight</const>
  </edit>
 </match>
</fontconfig>
EOF
show_msg "Changing font settings for current user"
sudo -u "$user" dbus-launch gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing rgba
sudo -u "$user" dbus-launch gsettings set org.gnome.settings-daemon.plugins.xsettings hinting slight
[[ "$(font_rendering_test)" = "Improved" ]]; exit_state
}

font_rendering_undo() {
show_func "Restoring original font rendering"
erase_pkg freetype-freeworld
rm -f /etc/fonts/local.conf
[[ ! "$(font_rendering_test)" = "Improved" ]]; exit_state
}

font_rendering_test() {
ls /usr/lib*/freetype-freeworld > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    printf "Improved"
else
    printf "Not improved"
fi
}
