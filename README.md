# CPC GuraBot

## A Roomba Dashboard

### Installation

1. Run (on Linux) `sudo apt-get install libsndfile portaudio aplay`.
2. Run `bundle install`.

### Development

1. Run `ruby index.rb` to start the Sinatra server (served at localhost:4567).

## Implementation Details

### Server
The Raspberry PI is running an `apache2` server. The main conf file is located at `/etc/apache2/apache2.conf`. 
The `Sinatra` roomba server runs on port `4567` be default. We wnated to enable access to the server through port 80, simply by typing `roomba.local` in the browser url bar. In order to do that, we added a reverse proxy configuration to apache:


1. Installed  a revesre proxy module via `a2enmod proxy_http` (see this [link](http://sharadchhetri.com/2013/08/02/how-to-install-mod_proxy-and-setup-reverse-proxy-in-apache-ubuntu/))
1. We created `/etc/apache2/sites-available/roomba`
1. We created a symlink to that file: `/etc/apache2/sites-enabled/roomba`
1. We removed all other symlinks from `/etc/apache2/sites-enabled/`, so that they odn't collide with our reverse proxy configuration.

Then we restarted apache by calling `sudo /etc/init.d/apache2 restart`

