require 'log.rb'
module MsgUtil
    class << self

    # send msg to all members in room
    # if specify pid, then not send to p (Player object)
    def send_msg_to_room(r, m, pid=nil)
        # tempariarily disable send msg to room because server is not in same network
            return
            if r.class == String
                room = Game::Room::Room.get(r)
            else
                room =r
            end
            return if room == nil
           room.objs.each{|k,v|
                if v[:o].is_a?(Pc) && (pid==nil || v[:o].id != pid)
                    send_room_msg(v[:o].id, room.id, m)
                end           
           }   
    end
    # ar: array of uid that should not send msg to 
    def send_msg_to_room2(r, m, ar=nil)
            if r.class == String
                room = Game::Room::Room.get(r)
            else
                room =r
            end
             p "ar=>#{ar.inspect}"
           room.objs.each{|k,v|

                if v[:o].is_a?(Pc) && (ar==nil || !ar.include?(v[:o].id) )
                    p "vo:#{v[:o].id}"
                    send_room_msg(v[:o].id, room.id, m)
                end           
           }   
    end

    # send fight msg
    def send_fight_msg_to_room(r, m, p1, p2, p=nil)
        send_msg_to_room3(r, m, p1, p2, p)
    end
        def send_msg_to_room3(r, m, p1, p2, p=nil)
            if r.class == String
                room = Game::Room::Room.get(r)
            else
                room =r
            end
           room.objs.each{|k,v|
               p "send_msg_to_room3=>#{k}=#{v.inspect}"
                if v[:o].is_a?(Pc) && (p==nil || v[:o].id != p.id)
                    m = translate_fight_result(m, p1, p2, v[:o])

                    p "send_room_msg #{v[:o].id}"
                    send_room_msg(v[:o].id, room.id, m)
                end           
           }   
    end

=begin
    # send room msg to <uid> in <roomid>
    def send_room_msg(uid, roomid, m)
         # send_msg(uid,"<rm>#{m}</rm>")
         # return


         # p "roomid class is #{roomid.class}"
         if roomid.class == Game::Room::Room
             roomid = roomid.id
         end
         m = m.gsub("\n", "")
         dir = "#{ g_FILEROOT}/message/#{roomid}"  
         FileUtils.makedirs(dir)   
         fname = "#{dir}/#{uid}"

         time = Time.now
         css_class="roommsg"
         st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"
         # msg = "<div class='#{css_class}'><span class=\"t\">[#{st}]</span>#{m}</span><br/>"
         msg = "<rm>[#{Time.now.to_i}]#{m}</rm>"
         print "\nwrite msg to #{uid}@#{roomid} #{fname}:#{msg}\n"
         append_file(fname, msg) 
     end

=end
    def clear_room_msg(uid)
        fname=get_user_room_msg_file(uid)

        begin
            if FileTest::exists?(fname)   

                    data = ""

                    open(fname, "r+") {|f|
                            f.truncate(0)
                        }
            end
        rescue Exception=>e
             # Rails.logger.error e
             err(e)
             p "==>exception #{e.inspect}"
        end
    end

    def get_user_room_msg_file(uid)
        "#{JU::Msg.get_msg_file(uid)}_room"
    end
    # roomid: room object
    #         room id 'room/yangzhou/kedian'
    #         "_any_": ignore room (when show2.erb javascript check room of msg with g_current_room_id)
    def send_room_msg(uid, roomid, m)
        # send_msg(uid,"<rm>#{m}</rm>")
        # return


        # p "roomid class is #{roomid.class}"
        #if roomid.class == Game::Room::Room
        #    roomid = roomid.id
        #end
        m = m.gsub("\n", "")
        m = "<rm id='#{roomid}'>#{m}</rm>"
        fname=get_user_room_msg_file(uid)

        time = Time.now
        css_class="roommsg"
        st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"
        # msg = "<div class='#{css_class}'><span class=\"t\">[#{st}]</span>#{m}</span><br/>"
        msg = "<rm1>[#{Time.now.to_i}]#{m}</rm1>"
        p "\nwrite msg to #{uid}@#{roomid} #{fname}:#{msg}\n"
        append_file(fname, msg) 
    end
    
    def get_room_msg(uid)

        fname=get_user_room_msg_file(uid)
        p "==>fname:#{fname}"
        ret = []
         ret2 = ""
         # p "ch=#{ch}"
         # p "====>context time #{time.inspect}, delete=#{delete}, filename=#{fname}"
        begin
            if FileTest::exists?(fname)   

                    data = ""

                    open(fname, "r+") {|f|
                            data = f.read
                            f.seek(0) 
                            f.truncate(0)
                        }
                        p "data:#{data}"
                        data.scan(/<rm1>\[(.*?)\](.*?)<\/rm1>/im){|m|
                             # p "match1:#{m.inspect}"
                             t = Time.at(m[0].to_i)
                              # p "==>time1=#{t}"
                             _t = Time.now

                        if (_t-t > 60 ) or t==nil
                           break
                        else 
                            # ret.push( m[1])
                            ret2 += m[1]
                        end
                        }

                p "ret:#{ret.inspect}"

            end
        rescue Exception=>e
             # Rails.logger.error e
             err(e)
             p "==>exception #{e.inspect}"
        end
        # ret.reverse!
        # p "get room msg for #{uid} ret=#{ret.inspect}"

        # return ret.join("\n")
        # p "ret2:#{ret2.inspect}"
        return ret2
    end    
#     def get_room_msg(uid, roomid)
#         dir = "#{ g_FILEROOT}/message/#{roomid}"  
#         FileUtils.makedirs(dir)   
#         fname = "#{dir}/#{uid}"
#         p "==>fname:#{fname}"
#         ret = []
#          ret2 = ""
#          # p "ch=#{ch}"
#          # p "====>context time #{time.inspect}, delete=#{delete}, filename=#{fname}"
#         begin
#             if FileTest::exists?(fname)   
#                       
#                    # open(fname, "r+") {|f|
#                    #                    ret = f.read
#                    #                    f.seek(0)
#                    #                
#                    #                    f.truncate(0)
#                    #                }
# 
#                         # if sys_msg
#                         #                             ret = ret.gsub(/^(\[....-..-.. ..:..).*?(\])/){|s| $1+$2}
#                         #                       else
#                       #        ret= ret.gsub(/^\[.*?\]/, "") 
#                         # end
# =begin              
#                     file=File.open(fname,"r+")  
#                     t = nil      
#                     ar = []
#                     file.each_line do |line|
#                         ar.push line
#                     end
#                     ar.reverse!
#                     
#                     ar.each{|line|
#                          p "line = #{line}"
#                         md = /<rm>\[(.*?)\](.*)<\/rm>$/.match(line)
#                         t = Time.at(md[1].to_i)
#                         p "==>time1=#{t}"
#                         _t = Time.now
#                    
#                         if (_t-t > 60 ) or t==nil
#                            break
#                         else 
#                             ret.push( md[2])
#                         end
#                     }
#                    #   context_time[:time] = t
#                      file.close
#                                 File.truncate(fname, 0)
# =end
# # =begin
#                     data = ""
#                    
#                     open(fname, "r+") {|f|
#                             data = f.read
#                             f.seek(0) 
#                             f.truncate(0)
#                         }
#                         data.scan(/<rm>\[(.*?)\](.*?)<\/rm>/im){|m|
#                             p "match1:#{m.inspect}"
#                              t = Time.at(m[0].to_i)
#                               p "==>time1=#{t}"
#                              _t = Time.now
#                    
#                         if (_t-t > 60 ) or t==nil
#                            break
#                         else 
#                             # ret.push( m[1])
#                             ret2 += m[1]
#                         end
#                         }
#                     #context_time[:time] = t
#                     # file.close
#                     #            File.truncate(fname, 0)                               
# # =end                                                 
#                                                  
#                                                  
#                   
#                  
#                 # p "ret:#{ret.inspect}"
#                
#             end
#         rescue Exception=>e
#              Rails.logger.error e
#              p "==>exception #{e.inspect}"
#         end
#         # ret.reverse!
#         # p "get room msg for #{uid} ret=#{ret.inspect}"
#         
#         # return ret.join("\n")
#         p "ret2:#{ret2.inspect}"
#         return ret2
#     end





    def query_msg(uid, ch_array, delete=false)
        JU::Msg.query_msg(uid, ch_array, delete)
    end

    def send_raw_msg(m)
        time = Time.now
        st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"

        msg = "<span class='rumor'><span class='t'>[#{st}]</span>#{m}<br/></span><!--br-->"
        JU::Msg.send_msg(-2, msg)

    end

    def send_bonus_msg(m)
        send_raw_msg("<div style='color:#ee6666'><span style='color:#ee6666'>[奖励]</span>#{m}</div>")
    end
         def send_msg(ch, m, type='')
             
                    # bRaw = false
                    p "send_msg:#{ch} #{m} #{type}"
                    return if m==nil || m.strip == ""
                    if ch.class == String 
                       if ch.to_i.to_s != ch
                           channel = JU::Msg.get_channel_by_name(ch)
                           if channel == nil
                               p "no this channel #{ch}"
                               return 
                           end
                           ch = channel[:id]
                       else
                           ch = ch.to_i
                       end
                    end
                    stype=""
                     css_class=""
                     case ch
                     when -1:stype="闲聊"
                         css_class = "chat"
                     when "chat":stype="闲聊"
                         css_class = "chat"
                     when -2:stype="江湖传闻" 
                         css_class = "rumor"
                     when "rumor":stype="江湖传闻"
                         css_class = "rumor"
                     when -3:stype="公告"
                          css_class = "system"
                     when "sys":stype="公告"
                          css_class = "system"
                     when -4:stype="天时"
                          css_class = "nature"
                     when "tianshi":stype="天时"
                          css_class = "nature"
                     when -5:stype="武林大会"
                          css_class = "wldh"
                     when "wldh":stype="武林大会"
                          css_class = "wldh"
                     when -6:stype="保卫襄阳"
                          css_class = "bwxy"
                     when "bwxy":stype="保卫襄阳"
                          css_class = "bwxy" 
                     when -7:stype="帮会门派"
                          css_class = "bh"
                     when "bh":stype="帮会门派"
                          css_class = "bh"
                     # else
                     #     bRaw = true
                     #     stype = ch # "<span style='color:#ee8888'>药王谷</spa>"
                     end


                     # if !bRow && stype != ""
                     if stype != ""
                         stype = "[#{stype}]"
                     end 

                     case type
                     when "task":stype+="任务"
                     end


                     onclick=""
                     # p "ch:#{ch}, player:#{player}"
                     if (ch == -1 || ch >0)
                         # player = current_player

                         # if player
                         # onclick = "onclick='reply(#{player.id}, \\'#{player.query('name')}\\')'"
                            onclick="onclick='onreply();' id='#{user_id}@#{user_name}##{Time.now.to_f}'"
                        # end
                     end

                  time = Time.now
                  st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"

                     # if bRow
                         # msg = "<span class='#{css_class}'><span class='t'>[#{st}]</span>#{stype}#{m}<br/></span><!--br-->"

                     # else
                         msg = "<span class='#{css_class}' #{onclick}><span class='t'>[#{st}]</span><span class='#{css_class}_t'>#{stype}</span>#{m}<br/></span><!--br-->"
                     # end
                
                JU::Msg.send_msg(ch, msg)
            end
            def delete_msg(ch)
                JU::Msg.delete_msg(ch)
            end
            def send_move_msg(p, newroom, old_room=nil, to=nil)
                if !p.is_ghost?         
                     if old_room && to
                         send_msg_to_room(old_room, li("#{p.query("name")}向#{Game::Room::Room.exitdef[to.to_sym]}离开了", "vola")+li("<script>remove_obj('#{Quest.escaped_id(getObjId(p))}');remove_vola();</script>"), p)             
                     end



                      # if @room
                      #     newroom = @room 
                      # else
                      #     newroom = p.query_room
                      # end   
                      if newroom  

                          if newroom.class == String
                              newroom = Game::Room::Room.get(newroom)
                          end

                          if newroom #&& newroom.query_obj(getObjId(p)) == nil
                              if p.is_a?(Pc)
                                  add_obj_msg = render_pc(p).gsub("\"", "|\"$")
                              elsif p.is_a?(Npc)
                                  add_obj_msg = render_npc(p).gsub("\"", "|\"$")
                              end

                              if p.is_a?(Human)
                                  send_msg_to_room(newroom, li("一条人影走了过来","vola"), p)
                              elsif p.is_a?(Insect)
                                  if p.subrace == "飞虫"
                                      send_msg_to_room(newroom, li("一#{p.unit}#{p.name}飞了过来","vola"), p)

                                 else
                                     send_msg_to_room(newroom, li("一#{p.unit}#{p.name}爬了过来","vola"), p)

                                 end

                              else
                                  send_msg_to_room(newroom, li("一#{p.unit}#{p.name}走了过来","vola"), p)
                              end
                              send_msg_to_room(newroom, li("<script>add_obj(\"#{add_obj_msg}\");remove_vola();</script>"), p)
                         end
                     end
                  end  
            end
            
            # default channel setting is 111110
            def msg_type_list
                ["闲聊", "江湖传闻","系统公告", "天时", "武林大会", "保卫襄阳", "帮会门派"]
            end
            def default_msg_channels
                "1111101"
            end
            def get_msg_file(ch)
                JU::Msg.get_msg_file(ch)
            end
        end # class << self
end