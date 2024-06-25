pacman -S archinstall
systemctl mask reflector.service
pacman-key --initsys
sudo pacman -Sy pacman-contrib

echo "NTP=time.google.com" >> /etc/systemd/timesyncd.conf
systemctl restart systemd-timesyncd
