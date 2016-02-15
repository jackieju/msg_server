def preload_modules
    if $preload_modules == nil
        $preload_modules = 1
    else
        return
    end
    log "[[[>>>>>preload_modules in #{File.dirname(__FILE__)}<<<<<]]\n", 6
      Dir["#{File.dirname(__FILE__)}/../**/*.rb"].each { |f| 
            load(f)
             # print "load #{f}\n"
          
         }

end


def launch_daily_job
    # do something seldomly (daily)
    #-----------------------------
    # wldh
    # cleanup_msg_file
    # maintain_db
    # update_tradables
    Process.detach fork{
        # delay it to prevent to much jobs running when start server
        sleep(3600)
        
       log_msg("cron process #{$$}: seldom job", "cron")
        Userext.connection.reconnect! 
        day = 0
        while(1)
            p "**************************"
             p "=====> seldom job(#{$$})     <===="
             p "**************************"
            begin
                 # maintain_fs if day == 1 # commented because different file need different cleanup frequency
                  # cleanup_msg_file("rumor", 3600*24*7) if Time.now.wday == 1
                  cleanup_msg_file_by_lines("rumor", 500, true)  # daily
                  cleanup_msg_file("bwxy", 3600*2) if Time.now.wday == 3
                  cleanup_msg_file("wldh", 3600*24*7, true) if Time.now.wday == 2
                  cleanup_msg_file("sys", 3600*24*30, true) if Time.now.day == 1 # montly
            rescue Exception=>e
                log_msg("!!Exception when executing job: #{exp_to_s(e)}", "err", 10)
                p "!!Exception when executing job: #{exp_to_s(e)}"
                err(e)
            end
 

            sleep (3600*24) # one day
            day +=1 
            day = 0 if day > 6
                
        end
    }
end

