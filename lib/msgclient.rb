require 'socket'

class MsgClient
    def initialize(server, port)
        @host = server
        @port = port
        reconnect
    end
    
    def reconnect
        @socket = TCPSocket.open(@host, @port)
    end
    
    def puts(m)
        begin
            @socket.puts(m)
        rescue Exception =>e
            p e
            err(e)
            reconnect
            @socket.puts(m)
        end
        ret = nil
        begin
            ret =@socket.gets
        rescue Exception =>e
            p e
            err(e)
            reconnect
            ret =@socket.gets
        end
        return ret
    end
    
    def close
        @socket.close
    end
end
# $msgClient = MsgClient.new(g_msg_server, g_msg_server_port)
#$msgClient  = MsgClient.new("127.0.0.1", 1234)
#p $msgClient.puts("send -1 3 hahaha")
