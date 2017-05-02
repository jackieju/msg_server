# msg_server

message socket server client + web server

message socket is for receiving message send from client, and store in local file system (/var/wh defined in server_settings.rb 
def g_FILEROOT
    "/var/wh"
end
)


web server is interface for retrieving message from web page/browser.



start server
===
./start_msg_server
or
./restart &         # restart mognrel ruby web server
./startcron         # restart cron  (for clean fs and run gserver)
./start_memcached   # restart memcached (for store user authentication)


migrate server
===
Copy the message channel you want to new server.
Usually only copy public channel exception tianshi(time reporting)
chat and frequent task message(bwxy, cycle less than game halt time) can be ignore if you stop game to migrate

public and long cycle task message need to copied
sys
rumor
bh
wldh





