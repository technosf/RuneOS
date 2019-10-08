ArchLinuxArm
---

On Linux

**Partition SD Card**
- Gparted

| Type    | No. | Label | Format | Size     |
|---------|-----|-------|--------|----------|
| primary | #1  | BOOT  | fat32  | 100MB    |
| primary | #2  | ROOT  | ext4   | the rest |

**Download**
- list: http://os.archlinuxarm.org/os/
```sh
# get user
whoami

sudo su
user=<user> # from previous command

# download - RPi2,3
file=ArchLinuxARM-rpi-2-latest.tar.gz
wget http://os.archlinuxarm.org/os/$file
```

### Flash SD card
```sh
# install bsdtar ("tar" will show lots of errors.)
apt install bsdtar

# extract
bsdtar xpvf $file -C /media/$user/ROOT
cp -rv --no-preserve=mode,ownership /media/$user/ROOT/boot/* /media/$user/BOOT
rm -r /media/$user/ROOT/boot/*
```

### Boot
- SCP/SSH with user|password : alarm|alarm
```sh
# set root's password to "rune"
su # password: root
passwd

# permit root SSH login
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# initialize pgp key (May have to wait for "haveged" to make enough entropy.)
pacman-key --init && pacman-key --populate archlinuxarm

# Or temporarily bypass key verifications
sed -i '/^SigLevel/ s/^/#/; a\SigLevel    = TrustAll' /etc/pacman.conf
```

### Install packages
```sh
# full upgrade
pacman -Syu

# packages
pacman -S alsa-utils avahi chromium cronie dnsmasq ffmpeg gcc hostapd ifplugd mpd mpc parted php-fpm python python-pip samba shairport-sync sudo udevil wget
#cifs-utils nfs-utils
```

### Custom packages and Configurations
```sh
# config files
wget -q --show-progress https://github.com/rern/RuneOS/archive/master.zip
bsdtar xvf master.zip --strip 1 --exclude=.* --exclude=*.md -C /
chmod 755 /root/* /srv/http/* /srv/http/settings/* /usr/local/bin/*
chown -R http:http /srv/http

# custom packages
pacman -U *.pkg.tar.xz

rm *.pkg.tar.xz
mkdir -p /var/lib/nginx/client-body  # fix - no directory found
ln -s /lib/libjsoncpp.so.{21,20}     # fix - older link

# set hostname
hostname runeaudio
echo runeaudio > /etc/hostname

# mpd directories
mkdir -p /mnt/MPD/{USB,NAS}
chown -R mpd:audio /mnt/MPD

# cron addons updates ( &> /dev/null suppress 1st crontab -l > no entries yet )
( crontab -l; echo '00 01 * * * /srv/http/addonsupdate.sh &' ) | crontab - &> /dev/null

systemctl daemon-reload
systemctl enable avahi-daemon cronie nginx php-fpm startup udevil
```
