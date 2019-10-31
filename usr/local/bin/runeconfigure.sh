#!/bin/bash

version=e2
addoversion=20191101

killall mpd
# remove cache and custom package files
rm -rf /var/cache/pacman/pkg/* *.pkg.tar.xz *.zip /root/armv6h

# RPi 4
hwcode=$( cat /proc/cpuinfo | grep Revision | tail -c 4 | cut -c 1-2 )
if [[ $hwcode == 11 ]]; then
	sed -i -e '/force_turbo/ d
' -e '/disable_overscan/ a\
[pi4]
dtoverlay=vc4-fkms-v3d
max_framebuffers=2
hdmi_force_hotplug=1
' /boot/config.txt
	mv /usr/lib/firmware/updates/brcm/BCM{4345C0,}.hcd
fi

# alsa
chmod -R 666 /var/lib/alsa  # fix permission
sed -i '/^TEST/ s/^/#/' /usr/lib/udev/rules.d/90-alsa-restore.rules   # omit test rules

# bluetooth (skip if removed bluetooth)
[[ -e /usr/bin/bluetoothctl ]] && sed -i 's/#*\(AutoEnable=\).*/\1true/' /etc/bluetooth/main.conf

# cron - for addons updates
( crontab -l &> /dev/null; echo '00 01 * * * /srv/http/addons-update.sh &' ) | crontab -

# lvm - remove invalid value
sed -i '/event_timeout/ s/^/#/' /usr/lib/udev/rules.d/11-dm-lvm.rules

# mpd - music directories
mkdir -p /mnt/MPD/{NAS,SD,USB}
chown -R mpd:audio /mnt/MPD

# mpd - create missing log file
touch /var/log/mpd.log
chown mpd:audio /var/log/mpd.log

# motd - remove default
rm /etc/motd

# netctl - allow write for http
chmod -R 777 /etc/netctl

# nginx - custom 50x.html
mv -f /etc/nginx/html/50x.html{.custom,}

# password - set default
echo root:rune | chpasswd

# ssh - permit root
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# user - set expire to none
users=$( cut -d: -f1 /etc/passwd )
for user in $users; do
    chage -E -1 $user
done

# wireless-regdom
echo WIRELESS_REGDOM="00" > /etc/conf.d/wireless-regdom

# startup services
systemctl daemon-reload

startup='avahi-daemon bootsplash cronie devmon@mpd localbrowser nginx php-fpm startup'

if [[ -e /usr/bin/chromium ]]; then
    # bootsplash - set default image
    ln -s /srv/http/assets/img/{NORMAL,start}.png
    
    # login prompt - remove
    systemctl disable getty@tty1
else
    startup=${startup/bootsplash }
    startup=${startup/localbrowser }
fi

[[ ! -e /usr/bin/avahi-daemon ]] && startup=${startup/avahi-daemon }

systemctl enable $startup

# fix sd card dirty bits if any
fsck.fat -trawl /dev/mmcblk0p1 | grep -i 'dirty bit'

# default settings:
# data and subdirectories
dirdata=/srv/http/data
dirdisplay=$dirdata/display
dirsystem=$dirdata/system
mkdir "$dirdata"
for dir in addons bookmarks coverarts display gpio lyrics mpd playlists sampling system tmp webradios; do
	mkdir "$dirdata/$dir"
done
# addons
echo $addoversion > /srv/http/data/addons/rr$version
echo $version > $dirsystem/version
# display
playback="bars buttons cover time volume"
library="album artist albumartist composer coverart genre nas sd usb webradio"
miscel="count label plclear playbackswitch"
for item in $playback $library $miscel; do
	echo 1 > $dirdisplay/$item
done
# system
echo runeaudio > /etc/hostname
sed -i 's/#NTP=.*/NTP=pool.ntp.org/' /etc/systemd/timesyncd.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo bcm2835 ALSA_1 > $dirsystem/audiooutput
echo 1 | tee $dirsystem/{localbrowser,onboard-audio,onboard-wlan} > /dev/null
echo RuneAudio | tee $dirsystem/{hostname,soundprofile} > /dev/null
echo 0 0 0 > $dirsystem/mpddb
echo '$2a$12$rNJSBU0FOJM/jP98tA.J7uzFWAnpbXFYx5q1pmNhPnXnUu3L1Zz6W' > $dirsystem/password

# set permissions and ownership
chown -R http:http "$dirdata"
chown -R mpd:audio "$dirdata/mpd"

rm $0
