
require 'rubygems' # required when run only this ruby file
require 'server_settings.rb'
require 'gserver'
require 'util_msg.rb'
require 'msg.rb'
require 'msg_common.rb'

class MsgServer < GServer
  def initialize(*args)
    super(*args)
    @ip_list = []
    # Keep an overall record of the client IDs allocated
    # and the lines of chat
    @@client_id = 0
    @@chat = []
    @@web_worker = 0
    @@job_worker = 0
  end
  
  # io is TCPSocket
  # called by every connection
  def serve(io)
      # p "io is #{io}" 
      
    # Increment the client ID so each client gets a unique ID
    @@client_id += 1
    my_client_id = @@client_id
    my_position = @@chat.size
    
    io.puts("Welcome to the chat, client #{@@client_id}!\n")
    # Leave a message on the chat queue to signify this client
    # has joined the chat
    @@chat << [my_client_id, ""]
    t_last_access = Time.now.to_i
    count = 0
    ns = ""
  
    begin
        line = io.readline()
        p "first line:#{line}"
        line = line.strip
        ns = line
        if $client_list.include?(ns) == false
            p "wrong client namespace:#{ns}"
            p "client quit"
            return
        end
       

    rescue Exception=>e
        p "exception:#{e}"
        err(e)
    end
    
    loop do 
        
      # Every 5 seconds check to see if we are receiving any data 
      #if IO.select([io], nil, nil, 2)
        # If so, retrieve the data and process it..
        #line = io.gets
        p "..."
        
        # read synchronizedly
       # p "#{io}:#{io.class.instance_methods.inspect}"
       #p "===>"+io.method(:readline).class.instance_methods.inspect
       #p "===>"+io.method(:readline).arity.to_s
        line = io.readline()
        p "line:#{line}"
        line = line.strip
        
        
        # log first msg 
        #log_msg("client #{@@client_id}:#{line}", "gserver") if count == 0
        #count += 1
        
        
        # If the user says 'quit', disconnect them
        if line == 'quit'
            p "client quit"
          @@chat << [my_client_id, ""]
          break
        end
        begin
        p "before handled"
        handler(io, line, ns)
        p "handled"
    rescue Exception=>e
        p "exception:#{e}"
        err(e)
    end
        # Shut down the server if we hear 'shutdown'
        #self.stop if line =~ /shutdown/
      
  

    end # loop
    
  end
  
  def ip_list
      @ip_list
  end
  
  def set_ip_list(list)
      @ip_list=list
  end
  
  # overridden
  # client: TCPSocket  
  def disconnecting(clientport)
      super
      p "disconnection from port #{clientport}"
  end
  
  # overridden
  # client: TCPSocket
  def connecting(client)
      super
      addr = client.peeraddr 
      # addr[2] => hostname
      # addr[3] => ip
      # addr[1] => port on client
      p("#{self.class.to_s} #{@host}:#{@port} client:#{addr[1]} " +
        "#{addr[2]}<#{addr[3]}> connect")
     
     if addr[2]=='localhost' || addr[3]=='127.0.0.1' || ip_list.include?(addr[3])
         log_msg("new connection from #{addr[3]}#{client}! connections #{connections}", "gserver")
         return true
     else
         p "client #{addr[3]} not in ip list #{ip_list}"
         return false
     end
  end
  
  def read_body(io)
      buf = ""
      count = 0
      line = io.readline
      while (line != "000\n" && count < 10000)
          buf += line
          count += 1 
          line = io.readline
      end
     return buf.chomp 
  end

  def handler(io, line, ns)
      
      if line.start_with?("k ")
          s = line[2..line.size-1].strip
          a = s.split(" ")
          params = {
              :k=>a[0],
              :u=>a[1],
              :n=>a[2],
              :ch=>a[3],
              :sex=>a[4]
          }
          receive_info(ns, params)
      elsif line.start_with?("send ")  # send_msg <ch> <type> <m>
          # s = line[5..line.size-1].strip
          # 
          # i = s.index(" ")
          # if i == nil 
          #     io.puts("error: invalid parameter for <ch>\n")
          #     return false
          # end  
          # 
          # ch = s[0..i-1]
          #         
          # while (s[i+1..i+1] == " ")
          #       i+=1
          # end
          # i2 = s.index(" ", i+1)
          # 
          # if  i2 == nil
          #     io.puts("error: invalid parameter <type>\n")
          #     return false
          # end
          # type = s[i+1..i2-1]
          # 
          # m = s[i2+1..s.size-1]
          # p "m:#{m}"
          # 
          # MsgUtil.send_msg(ch, m, type) 
          s = line[5..line.size-1].strip
            i = s.index(" ")
            if i == nil 
                io.puts("error: invalid parameter for <u>\n")
                return false
            end  
            p "s:#{s}, i=#{i}"
            ch = s[0..i-1]
            p "ch:#{ch}"

            while s[i+1..i+1] == " "
                  i+=1
            end

            type = s[i+1..s.size-1].strip
            p "type:#{type}"

            m = read_body(io)
            p "m:#{m}"

            MsgUtil.send_msg(ns, ch, m, type) 
      elsif line.start_with?("sendr ") # send_room_msg  <u> <r> <m>
          s = line[6..line.size-1].strip
          i = s.index(" ")
          if i == nil 
              io.puts("error: invalid parameter for <u>\n")
              return false
          end  
          u = s[0..i-1]
          p "u:#{u}"
          
          while s[i+1..i+1] == " "
                i+=1
          end
         
          r = s[i+1..s.size-1].strip
          p "r:#{r}"
          
          m = read_body(io)
          p "m:#{m}"
   
          MsgUtil.send_room_msg(ns, u, r, m)
      elsif line.start_with?("senda ") # send_raw_msg <m>
          s = line[6..line.size-1].strip
          MsgUtil.send_raw_msg(ns, s)
      
      elsif line.start_with?("del ") # delete_msg
          s = line[4..line.size-1].strip
      
          MsgUtil.delete_msg(ns, s)

      elsif line.start_with?("delr ") # clear_room_msg
          s = line[5..line.size-1].strip
      
          MsgUtil.clear_room_msg(ns, s)
      
      elsif  line.start_with?("if ") # info
          s = line[3..line.size-1].strip
          if s.index("cron")
              @@job_worker +=1
          elsif s.index("mongrel")
              @@web_worker += 1
          end
          log_msg(s, "gserver")
          log_msg("connections #{connections}, job #{@@job_worker}, web #{@@web_worker}", "gserver")
          
      else
          io.puts("error: invalid command\n")
          return false
      end    
      io.puts("ok\n")
      
  end
end


def start_msg_server
    server = MsgServer.new(12345, "0.0.0.0")
    server.audit = true 
    server.set_ip_list(["115.29.246.68"])
    server.start(100) # start with maximum 20 connection
    p "server started on port #{server.port}"
    log_msg("server started on port #{server.port}", "gserver")
    #loop do
    #  break if server.stopped?
    #end
    server.join
    puts "Server has been terminated"
    log_msg("Server on port #{server.port} has been terminated ", "gserver")
    
end
#start_msg_server