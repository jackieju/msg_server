def g_valid_msg_client_ip
    "115.29.246.68"
end

def g_memcached_port
    "11231"
end

def g_launchables
   # ["battled", "global_quest", "rank", "daily", "hourly", "5min", "refresh", "sec", "sec2", "calloutd"]
   #["cron_gserver"]
   ["daily"]
   #["battled", "global_quest", "rank", "daily", "hourly", "5min", "refresh", "sec", "sec2", "statisticsd"]
   
end

def g_FILEROOT
    "/var/wh"
end

def g_memcacheds
    {
        "11231"=>{
            #:size=>256
            :size=>32
        }
    }
end

def g_clusters
    ports1 = 7620..7629
    #ports2 = 6832..6834
    #ports3 = 7025..7025
    
    clusters=[ports1]
    return clusters
end