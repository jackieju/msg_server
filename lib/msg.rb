require 'rubyutility'
require 'log.rb'

module JU
module Msg
    # class _Msg 
    # 
    # 

        class << self
            # @@_channels
            # @@_channels_by_id
            # @@_public_channels 
            # @@_system_channels 
            # @@fs_root
            def init(fs)
                @@fs_root = fs
            end
            def reset
                @@_channels = {}
                @@_channels_by_id = {}
                @@_public_channels = []
                @@_system_channels = []
                @@fs_root = "."
                
            end
            
            def all_channels
                channels
            end
            def channels
                @@_channels
            end
            def add_channel(name, id, dname, msg_expire=3600*24*30, is_public=true, system=true)
                h = {
                    :name=>name,
                    :id=>id,
                    :msg_expire=>msg_expire
                }
                @@_channels[name.to_s] = h
                @@_channels_by_id[id.to_s] = h
                @@_public_channels.push(name) if is_public
                @@_system_channels.push(name) if system
            end
            
            def max_msg_per_file
                200
            end
            # =========== override
            def fs_root
                # "#{g_FILEROOT}/message"
                @@fs_root
            end
            
            # message from public channel can be seen by anyone
            def public_channel
                # ["chat", "rumor", "wldh", "tianshi", "bwxy", "bh"]
                @@_public_channels
            end
            
            # message from system_channel will always be shown
            def system_channel
                # ["sys", "rumor", "chat", "wldh", "tianshi", "bwxy", "bh"]
                @@_system_channels
            end
            
            # get msg file by channel
            # channel can be number or string
            def get_msg_file(ch)
                if (ch.class == Fixnum || ch.to_i.to_s == ch )
                    id = ch.to_i
                    if id < 0 
                        _ch = @@_channels_by_id[id.to_s]
                        if _ch
                            dir = _ch[:name]
                        else
                            dir = id.to_s
                        end

                    else
                        dir = id%100
                    end
                else
                    dir = ch
                    _ch = channels[ch.to_s]
                    if _ch
                        id = _ch[:id].to_i
                    end
                end

                dir = "#{fs_root}/#{dir.to_s}"  
                FileUtils.makedirs(dir)   
                fname = "#{dir}/#{id}"
                # p "file:#{fname}"
                # p "self:#{self}"
                return fname

            end
            # ===== end of override =======
            
            def query_filedata(uid)
                json = {}
                id = uid.to_i
                 dir = id%100
                dir = "#{fs_root}/#{dir.to_s}/#{id}_lastread"
                FileUtils.makedirs(dir)
                fname = "#{dir}/jsondata" 
                # p "filename #{fname}"

                begin
                    if FileTest::exists?(fname) 
                        data= nil  
                        open(fname, "r") {|f|
                               data = f.read
                               # f.seek(0)
                               # f.write("") 
                               # f.truncate(0)
                           }
                           # p "data=#{data.inspect}"
                           json = JSON.parse(data) if data
                    end
                rescue Exception=>e
                     # logger.error e
                     p e.inspect
                     pe(e)
                     
                end

                return json

            end
            def save_filedata(uid, data)
                # p "save_filedata #{data.inspect}"
                json = data.to_json
                # p "save_filedata json=#{json}"
                id = uid.to_i
                 dir = id%100
                dir = "#{fs_root}/#{dir.to_s}/#{id}_lastread"
                FileUtils.makedirs(dir)
                fname = "#{dir}/jsondata" 
                begin

                        open(fname, "w+") {|f|
                               f.write(json)
                           }


                rescue Exception=>e
                     err e
                     pe(e)
                     
                end


            end
            
            
            # ======= public method
            def delete_msg(ch)
               fname = get_msg_file(ch)
                begin
                    if FileTest::exists?(fname) 
                        aFile = File.new(fname, "w")
                        aFile.puts ""
                        aFile.close
                    end

                rescue Exception=>e
                     p e
                end
            end


            
            # uid=> receiver 
            # ch_array=> channels
            # delete=> delete message afterawards
            def query_msg(uid, ch_array, delete=false)

                # p "++++++>start query_msg: #{Time.now.to_f}"
                d = ""
                # time = t[:time]
                data = query_filedata(uid)
                if data
                    lastread = util_get_prop(data, "lastread")
                     # p "=>last read = #{lastread.inspect}, data=#{data}"
                    if lastread.class==String
                        lastread= JSON.parse(lastread)
                    end
                end
                
                __logf__

                lastread = {} if !lastread
                # p "=>last read = #{lastread.inspect}, #{lastread['191']}, #{lastread["191"]},  #{lastread["191"]}"
                
                ch_array.each{|ch|
                    _t= lastread[ch.to_s]
                    # p "_t=#{_t}, ch=#{ch}, #{lastread[ch.to_s]}"
                    if _t
                        t = Time.at(_t)
                    else
                        # if system_channel.include?ch
                        #     if ch == 'rumor' || ch == -2 
                        #         t = Time.now - 3600*24*1
                        #     elsif ch == 'wldh' || ch == -5 || ch == 'bwxy' || ch == -6 || ch=='bh' || ch == -7
                        #         t = Time.now - 3600
                        #     elsif ch == 'chat' || ch == -1
                        #         t = Time.now - 15
                        #     else
                        #         t = Time.now - 3600*24*7
                        #     end
                        # else
                        #    t =   Time.now - 3600*24
                        # end

                    end
                    
                    # p "last_read:#{t}"
                    if system_channel.include?ch
                        t2 =   Time.now - channels[ch.to_s][:msg_expire]
                        if !t || t2 > t
                            t = t2
                        end
                    end
                    
                    c = {:time=>t}
                    # p "c:#{c.inspect}"
                    # p "ttt=>#{t.inspect}, ch=#{ch.inspect}, pch=#{public_channel.inspect}"
                   if system_channel.include?ch

                        r = get_public_msg(ch, c)
                        d += r[:data]
                        if (r[:time] && (r[:time] <=> t)>0)
                            # c[:time] = time
                            lastread[ch.to_s] = r[:time].to_f+0.000001 
                        end
                    else

                        r = get_msg(ch, delete, c)
                        d += r[:data]
                        # p "->query_msg r=#{r.inspect}, t=#{t.inspect}, data=#{r[:data]}"
                        lastread[ch.to_s] = r[:time].to_f+0.000001 if r[:time] && (r[:time] <=> t) > 0
                    end
                }
                __logf__
                # p "=>lastread=#{lastread}"
                if delete
                    util_set_prop(data, "lastread", lastread)
                    save_filedata(uid, data)
                end
                # delete_msg(ch)
                # p "===>d=#{d}"
                        # p "++++++>end query_msg: #{Time.now.to_f}"

                return d
            end
            
            # retrieve and delete message
            def take_msg(uid,ch_array, t)
                query_msg(uid, ch_array, t, true)
            end

            def get_public_msg(ch, t)
                get_msg(ch, false, t)
            end
            
            def get_msg(ch, delete=false, context_time=nil)
                # if ch == -1 || ch == "chat"
                #                p "get chat msg #{ch}, c:#{context_time}"
                #            end
                    
                __logf__
               ret = {
                    :data => ""
                }
                sys_msg = system_channel.include?ch
                  fname=get_msg_file(ch)
                 time  = nil
                 if context_time
                     time = context_time[:time]
                 end
                 # p "ch=#{ch}"
                 # p "====>context time #{time.inspect}, delete=#{delete}, filename=#{fname}"
                begin
                    if FileTest::exists?(fname)   
                              # aFile = File.new(fname,"r")
                        if delete 
                           open(fname, "r+") {|f|
                               ret[:data] = f.read
                               f.seek(0)
                               # f.write("") 
                               f.truncate(0)
                           }
                           # p "===>messsage: #{ret[:data]}"
                                if sys_msg
                                       ret[:data] = ret[:data].gsub(/^(\[....-..-.. ..:..).*?(\])/){|s| $1+$2}
                                else
                                       ret[:data] = ret[:data].gsub(/^\[.*?\]/, "") 
                                end
__logf__(fname)
                        else

                            # p "filename=#{fname}"
                            ret[:data] = ""
                            file=File.open(fname,"r")  
                            t = nil      
__logf__(fname)
                            # here should split by "<!--br-->" but maybe cause low performance
                            # file.each_line do |line|
                            #                    ar.push(line) if line !=nil && line.strip != nil
                            #                end
                            _data = file.read()
__logf__(_data.size)   
                            # ar = []
                            ar = _data.split("\n")
                            # 
                            # line = ""
                            # i = _data.size-1
                            # 
                            # while i>=0
                            #     c = _data[i..i]
                            #     if c == "\n"
                            #         if line.size>0
                            #             ar.push(line)
                            #             line = ""
                            #             break if ar.size >= max_msg_per_file
                            #         end
                            # 
                            #     else
                            #         line = c+line
                            #     end
                            #     i -=1
                            # 
                            # end
                            # ar.push(line) if line.size > 0
                            
__logf__(ar.size)    
                            if ar.size > max_msg_per_file # max message number in one get is 200
                                ar = ar[ar.size-max_msg_per_file..ar.size-1]
                                
                            end

__logf__()                            
                            ar.reverse!
__logf__(ar.size)
                            

                            # record last read time
                            if ar.size >0
                                md = /<span class='t'>\[(.*?)\]<\/span>(.*)$/.match(ar[0])
                               if md && md[1] 
                                _t =  Time.parse(md[1]) 
                                ret[:time] = _t if (_t <=> time) >0
                                end
                            end

                            ar.each{|line|
                                # p "line = #{line}"
                                md = /<span class='t'>\[(.*?)\]<\/span>(.*)$/.match(line)
                                if !md
                                    p "parse failed! line=#{line}"
                                    next #if !md
                                end
                                t = Time.parse(md[1])
                                # p "==>msg time=#{ret[:time].inspect} #{ret[:time].to_f}"
                                # p "context time #{time.to_f}"
                                 # p "md1=#{md[1].inspect}==>md2=#{md[2].inspect}"
                                # p t <=> time
                                 # p "sys_msg=#{sys_msg},#{md[1].to(15)} "

                                if ( time && t&& (t <=> time) > 0 ) or time==nil
                                    # p "=====>111"
                                    #                              p "[#{md[1].to(15)}]#{md[2]}\n"+ret[:data] 
                                    if sys_msg

                                        # ret[:data] = "[#{md[1].to(15)}]#{md[2]}\n#{ret[:data]}"
                                        ret[:data] = line + ret[:data]
                                        # p ret[:data]
                                    else
                                        ret[:data] = "#{md[2]}\n"+ret[:data] 
                                    end
                                else 
                                    break
                                end
                            }
                            # context_time[:time] = t
                            file.close
                        end


                              # aFile.close
                    end
                rescue Exception=>e
                     # logger.error e
                     p "==>exception #{e.inspect}"
                     pe(e)
                end
                __logf__
                # p "ret=#{ret.inspect}" if ch == -1 || ch == "chat"
                return ret
            end
            
            
       
             def send_msg(ch, msg)
                 fname = get_msg_file(ch)
                  p "==>send msg #{msg} to file #{fname}"
                 append_file(fname, msg)               
             end
             
             def get_channel_by_id(_id)
                 @@_channels_by_id[_id.to_s]
             end
             
             def get_channel_by_name(name)
                 @@_channels[name.to_s]
             end
             # ===== end of public method
        # end
    end # class << self
end # module Msg

end # module JU

=begin test
JU::Msg.reset
# JU::Msg.init("#{g_FILEROOT}/message")

JU::Msg.add_channel("chat", -1, "闲聊", 300, true, true)
JU::Msg.add_channel("rumor", -2, "江湖传闻", 3600, true, true)
JU::Msg.add_channel("sys", -3, "公告", 3600, true, true)
JU::Msg.add_channel("tianshi", -4, "天时", 60, true, true)
JU::Msg.add_channel("wldh", -5, "五林大会", 3600*24, true, true)
JU::Msg.add_channel("bwxy", -6, "保卫襄阳", 300, true, true)
JU::Msg.add_channel("bh", -7, "帮会门派", 3600, true, true)
p JU::Msg.all_channels.inspect
JU::Msg.get_msg(-1)
# JU::Msg.send_msg("sys", "dfd")
=end

