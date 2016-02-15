require 'gserver'

class MsgServer < GServer
  def initialize(*args)
    super(*args)
    @ip_list = []
    # Keep an overall record of the client IDs allocated
    # and the lines of chat
    @@client_id = 0
    @@chat = []
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
    
    
    loop do 
        
      # Every 5 seconds check to see if we are receiving any data 
      #if IO.select([io], nil, nil, 2)
        # If so, retrieve the data and process it..
        #line = io.gets
        p "..."
        line = io.readline
        p "line:#{line}"
        line = line.strip
        # If the user says 'quit', disconnect them
        if line == 'quit'
            p "client quit"
          break
        end
        begin
        p "before handled"
        io.puts "got #{line.chop}\n"
        p "handled"
    rescue Exception=>e
        p e
        err(e)
    end
        # Shut down the server if we hear 'shutdown'
        #self.stop if line =~ /shutdown/
      
  

    end # loop
    
  end

end
server = MsgServer.new(1234, "0.0.0.0")

server.start() # start with maximum 20 connection
p "server started on port #{server.port}"

server.join
puts "Server has been terminated"