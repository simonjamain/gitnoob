DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
gem install colorize
chmod a+x "$DIR/gitnoob.rb"
sudo ln -s "$DIR/gitnoob.rb" /bin/gitnoob