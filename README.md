# msg_server
overview
===
message socket server client + web server

message socket is for receiving message send from client, and store in local file system (/var/wh defined in server_settings.rb 
def g_FILEROOT
    "/var/wh"
end
)


web server is interface for retrieving message from web page/browser.

reserved mongrel port is from 7620...7699


install
===
sudo yum install sqlite-devel
 gem install sqlite3 

start server
===
./start_msg_server
or
./restart &         # restart mognrel ruby web server
./startcron         # start cron  (currently 2 corns: for clean fs and run gserver)
                    # ./cron_restart to restart all cron
./start_memcached   # restart memcached (for store user authentication)



migrate server
===
1. configure the port memcached
edit start_memcached
edit server_settings.rb
change 
    msg_server_prefix 
    g_msg_server 
    g_memcached_port 

2. change host in sync_file

3. check whether need to change configure of msg server on wh server

4. make link for apache host config
sudo ln -s /var/www/msg_server/config/httpd_msg.conf /etc/httpd/conf/hosts/httpd_msg.conf

5. Copy the message channel you want to new server.
Usually only copy public channel exception tianshi(time reporting)
chat and frequent task message(bwxy, cycle less than game halt time) can be ignore if you stop game to migrate

public and long cycle task message need to copied
sys
rumor
bh
wldh





