require "server_settings.rb"

def retrieve_corns
    command = "ps aux | grep ruby | grep crond | grep msg_server"
        p "command=>#{command}"
        r = `#{command}`
        p "==>r=#{r}"
        # if $?.exitstatus != 0
        #             raise Exception.new("git command=>#{command}\n return:\n#{r}")
        #         end
    crons = {}
    r.scan(/^(\d+)\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+)\s+(.*?)\s+(\w+)\s+(.*?)\s+(\d+:\d+)\s+(ruby script\/crond.*?)$/){|m|
        cmd = m[10]
        cmd.strip!
        cron_id = nil
        cmd.scan(/ruby script\/crond cron[_\d\w]+\s+([\d\w]+)\s+([\d\w]+)$/){|mm|
            
            cron_id = mm[0]
        }
        crons[cron_id.to_s]={
            :pid=>m[1],
            :mem1=>m[3],
            :mem2=>m[4],
            :mem3=>m[5],
            :cmd=>m[10]
        }
        
    }
    # crons.sort!{|a,b|
    #     a[:pid]<=>b[:pid]
    # }
    
    return crons
   
end

def retrieve_mongrels
    mongrels = {}

   command = "ps aux | grep ruby | grep mongrel_wh"
       p "command=>#{command}"
       r = `#{command}`
       p "==>r=#{r}"
   # r.scan(/^(\d+)\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+)\s+(.*?)\s+(\w+)\s+(.*?)\s+(\d+:\d+)\s+\/usr\/bin\/ruby \/usr\/bin\/mongrel_rails start -d -e production -p (\d+)-P (.*?) -l (.*?)$/){|m|
   r.scan(/^(\d+)\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+)\s+(.*?)\s+(\w+)\s+(.*?)\s+(\d+:\d+)\s+.*?mongrel_rails start.*?-p (\d+) -P (.*?) -l (.*?)$/){|m|

       mongrels[m[10].to_s]={
           :pid=>m[1],
           :cpu=>m[2],
           :mem1=>m[3],
           :mem2=>m[4],
           :mem3=>m[5],
           :port=>m[10],
           :pid_file=>m[11],
           :log_file=>m[12]
       }
   }
   
   return mongrels
end

def check_mongrels
    mongrels = retrieve_mongrels
    
    clusters=g_clusters
    index = 1
    
    clusters.each{|ports|
        ports.each{|port|
    	    c= mongrels[port.to_s]
    	    if c == nil
    	        if index == 1
    	            command = "mongrel_rails cluster::restart -C config/mongrel_cluster.yml --only #{port} --clean"
	            else
	                command = "mongrel_rails cluster::restart -C config/mongrel_cluster#{index}.yml --only #{port} --clean"
	            end
	            r = `#{command}`
	            p r
	        end
        }
	    index +=1
    }
end

def check_crons
    crons = retrieve_corns
    p "crons:#{crons.inspect}"
    p "g_launchables:#{g_launchables}"
    g_launchables.each{|l|
        if crons[l] == nil
            command = "nohup ruby script/crond cron_#{l} #{l} msg_server> /dev/null 2>&1"
            p command
            # r = `#{command}`
            r = system(command) # using `` will cause no return when launch hourly job
            p r
        end
    }
end

def retrieve_memcached
    command = "ps aux | grep memcached"
        p "command=>#{command}"
        r = `#{command}`
        p "==>r=#{r}"
        # if $?.exitstatus != 0
        #             raise Exception.new("git command=>#{command}\n return:\n#{r}")
        #         end
    ar = []
    r.scan(/memcached -d -u root -m (\d+) -p (\d+)/){|m|
        port = m[1]
        port.strip!
        ar.push(port)        
    }

    
    return ar
end
def check_memcached
    
    ar = retrieve_memcached
    p "ar:#{ar}"
    p "g_memcacheds:#{g_memcacheds}"
    g_memcacheds.each{|k, v|
        if ar.include?(k) == false
            port = k
            command = "memcached -d -u root -m #{v[:size]} -p #{port}"
            p command
            # r = `#{command}`
            r = system(command) # using `` will cause no return when launch hourly job
            p r
        end
    }
end

def check_gserver
    command = "ps aux | grep ruby | grep cron_gserver"
        p "command=>#{command}"
        r = `#{command}`
        p "==>r=#{r}"
        # if $?.exitstatus != 0
        #             raise Exception.new("git command=>#{command}\n return:\n#{r}")
        #         end
    crons = {}
    r.scan(/^(\d+)\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+)\s+(.*?)\s+(\w+)\s+(.*?)\s+(\d+:\d+)\s+(ruby script\/crond.*?)$/){|m|
        cmd = m[10]
        cmd.strip!
        
        crons[0]={
            :pid=>m[1],
            :mem1=>m[3],
            :mem2=>m[4],
            :mem3=>m[5],
            :cmd=>m[10]
        }
        
    }
      
    if crons.size == 0
        command = "nohup script/start_msg_server cron_gserver crond> /dev/null 2>&1 &"
        p command
        r = system(command) # using `` will cause no return when launch hourly job
        p r
    end 
    
end

def check_server
    check_mongrels
    check_crons
    check_memcached
    check_gserver
end
