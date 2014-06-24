# Update apt repository
apt-get update
apt-get -y upgrade

test $USERNAME  || { echo "USERNAME has to be set" >&2; exit 1; }
test $RAILS_ENV || { echo "USERNAME has to be set" >&2; exit 1; }

# Set up system dependencies
BASICS='git build-essential postgresql postgresql-contrib libpq-dev git sqlite3 libsqlite3-dev libpcre3-dev lzop libxml2-dev libxslt-dev libcurl4-gnutls-dev libitext-java ruby ruby-dev'
echo $BASICS | xargs apt-get install -y

DOCSPLIT_DEPS='graphicsmagick pdftk xpdf poppler-utils libreoffice libreoffice-java-common tesseract-ocr ghostscript'
echo $DOCSPLIT_DEPS | xargs apt-get install -y

cd /home/$USERNAME

# approve github ssh host key
grep -q github .ssh/known_hosts 2>/dev/null || ssh-keyscan -t rsa github.com > .ssh/known_hosts

#git clone https://github.com/documentcloud/documentcloud.git

# Install gems
cd documentcloud
#git checkout --track -b bundler origin/bundler
#git pull
gem install bundler --no-ri --no-rdoc
bundle install
#git checkout master
#git pull

# Ensure that the secrets directory exists
test -e secrets || { cp -r config/server/files/secrets ./secrets; }

# disable ssh dns to avoid long pause before login
grep -q '^UseDNS no' /etc/ssh/sshd_config || echo 'UseDNS no' >> /etc/ssh/sshd_config
/etc/init.d/ssh reload

# replace annoying motd with new one
rm -f /etc/motd
cat >/etc/motd <<'EOF'

______                                      _   _____ _                 _
|  _  \                                    | | /  __ \ |               | |
| | | |___   ___ _   _ _ __ ___   ___ _ __ | |_| /  \/ | ___  _   _  __| |
| | | / _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __| |   | |/ _ \| | | |/ _` |
| |/ / (_) | (__| |_| | | | | | |  __/ | | | |_| \__/\ | (_) | |_| | (_| |
|___/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__|\____/_|\___/ \__,_|\__,_|

EOF
uname -a | tee -a /etc/motd
