require 'socket'      # Sockets 是标准库

 
s = TCPSocket.open("localhost", 1234)
 puts "line:"+s.gets
 puts s.puts("ha\n")
 #puts s.puts("fe\n")
 
print "12"
begin
    IO.select [s]
    res = ""
    chunk = ""
    
while chunk = s.read_nonblock(4096)
				res = res + chunk
			end
rescue
end
p "read line:"+res
#p "gets:"+s.gets
begin
    IO.select [s]
    
    ret = ""
    chunk = ""
while chunk = s.read_nonblock(4096)
				res = res + chunk
			end
rescue
end
p "read line2:"+res
#p "gets:"+s.gets
begin
    IO.select [s]

    ret = ""
    chunk = ""
while chunk = s.read_nonblock(4096)
				res = res + chunk
			end
rescue
end
p "read line3:"+res
#p s.gets
#while line = s.gets   # 从 socket 中读取每行数据
#  puts "line:"+line.chop      # 打印到终端
#end
p "done"
s.close               # 关闭 socket
