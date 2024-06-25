pacman -S archinstall
systemctl mask reflector.service
pacman-key --initsys
sudo pacman -Sy pacman-contrib

echo "NTP=time.google.com" >> /etc/systemd/timesyncd.conf
systemctl restart systemd-timesyncd
echo "FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org"
