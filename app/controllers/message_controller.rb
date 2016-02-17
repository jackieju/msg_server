require 'msg.rb'
require 'utility.rb'
require 'emotes.rb'

class MessageController < ApplicationController
    # after_filter :cors_set_headers
    before_filter :cors_preflight_check
    
    def test
        session[:test] = 1000
        
    end
    def test2
        p "cookie:#{cookies.inspect}"
        render :text=>session[:test]
    end
    
    def pre_action
        # p "pre_action"
        # @logf = true
       super
       @pass_cb = true
       # p "pre_action2"
    end
    def et
        render :text=>Time.now.to_i
    end
    
    # log in
    def et5
        # session[:uid] = 322323
        # raise Exception.new("Denied")
        # success("#{session[:uid] }")
        # return
        efi = params[:efi]
        key = params[:k]
        
        # get by key
        hash = $memcached.get(key.to_s)
        if hash == nil
            p "get session by key #{key} failed"
            raise Exception.new("Denied")
        end
        
        # verify and get uid
        # uid = (efi.to_i^key.to_i>>2)>>2
        decode_uid_key(key, efi)
        session[:uid] = uid
        
        
        p "uid=#{uid}"
        
        # delete by key
        # $memcached.delete(key.to_s)
        
        success
        
        p "login user #{uid} ok."
    end
    
    def check_session_exist
        key = request.headers['X_MKEY']
        p "==>mkey:#{key}"
        hash = $memcached.get(key.to_s)
        if hash == nil
            p "get session by key #{key} failed"
            raise Exception.new("Denied")
        end
        p "get session #{hash.inspect}"
        $uid = get_uid_from_header
        p "get uid #{$uid}, #{hash[:u]}"
        if hash[:u].to_i != $uid
            p "get session by key #{key} failed"
            raise Exception.new("Denied")
        end
    end
    
    def get_uid_from_header
        key = request.headers['X_MKEY']
        efi = request.headers['X_EFI']
        p "mkey:#{key}, efi:#{efi}"
        return nil if !key || !efi
        
        # return (efi.to_i^(key.to_i>>2))>>2
        return decode_uid_key(key, efi)
    end
    
    def getroommsg
        check_session_exist

        r = MsgUtil.get_room_msg(user_id)
        
        p "===>get_room_msg(#{user_id}):#{r}"
        render :text=>r
    end
    
    def _get(uid, args)
        __logf__
         @delete = args[:delete]
            if !@delete
                @delete = 0
            else
                @delete = @delete.to_i
            end

            # @t = params[:t]
            # if !@t || @t.to_i == 0
            #     data = query_filedata(user_data[:id])
            #     if !data || data[:lastreadmsg] == nil 
            #         @t = Time.at(1)
            #     else
            #         @t = Time.at(data[:lastreadmsg])
            #     end
            # else
            #     @t = Time.at(t.to_i)
            # end

            # @ch = params[:ch]
            #    if !@ch
            #        @ch = "public_user"
            #    end

            @type = args[:type]
            if !@type 
                @type = "plain"
            end

            @type2 = args[:type2]
            if !@type2 
                @type2 = "text"
            end
            # c = {:time => @t}
            # p "==>lastreadtime=#{@t.inspect}"
            @msg = ""
            
            #ch = session[:ch]
            
            ch = player.ch
            #p "==>player channel:#{ch}"
            
            # p "ch=#{ch}"
            ch = MsgUtil.default_msg_channels if ch == nil || ch ==""
            channels = [uid, "tianshi", "sys"] # default channel

            # keys = ["闲聊","江湖传闻","系统公告", "天时", "武林大会"]

            # if params[:s] && params[:s].to_i==1
            #     channels.push("sys")
            # end
            #p "===>111"
            __logf__

            if args[:c] && args[:c].to_i==1
                if ch[0..0] != "0"
                    channels.push("chat")
                end
            end
            if args[:r] && args[:r].to_i==1
                if ch[1..1] != "0"
                    channels.push("rumor")
                end
            end
            if args[:w] && args[:w].to_i==1
                if ch[4..4] != "0"
                    channels.push("wldh")
                end
            end
            if args[:b] && args[:b].to_i==1
                if ch[5..5] != "0"
                    channels.push("bwxy")
                end
            end
            if args[:h] && args[:b].to_i==1
                if ch[6..6] != "0"
                    channels.push("bh")
                end
            end
            __logf__
            #print "===>channels:#{channels}"

                # channels = channels.concat(system_channel)
            # p "channels:#{channels}" if is_adm?(uid)
            begin
                #p "--->1, uid:#{uid}, channels:#{channels}, delete:#{@delete}"
                @msg = MsgUtil.query_msg(uid, channels, @delete.to_i ==1)
                #p "--->2, uid:#{uid}, channels:#{channels}"
                
            rescue Exception=>e
                pe e.inspect
            end
            p "msg=#{@msg}" 
                 # p "msg=#{@msg}" if is_adm?(uid)
            if (@type == "plain")
                @msg = @msg.gsub(/<.*?>/,"")
            end
            __logf__

             @msg.strip!


             # sort all messages from different channel by time (earlier to later)
             sort_msg = @msg.split("<!--br-->")
             sorted_msg = []
             sorted_msg2 = []
             __logf__(sort_msg.size())
             # time = nil
             sort_msg.each{|line|
                # md = /<span class='t'>\[(.*?)\]<\/span>(.*)$/.match(line)
                md = /<span class=[\'\"]t[\'\"]>\[(.*?)\]<\/span>/.match(line)

                if !md
                    p "parse time failed: line=#{line}"
                    next #if !md
                end
                t = Time.parse(md[1])
                # p "t=>#{t.inspect}" if is_adm?(uid)
                next if t == nil

                # p "sorted_m__logf__sg size #{sorted_msg.size}" if is_adm?(uid)
                if sorted_msg.size == 0
                    sorted_msg[0]=t
                    sorted_msg2[0]=line
                    next
                end

                # p  "sorted_msg2 size #{sorted_msg.size}" if is_adm?(uid)
                c1 = 0
                inserted = false
                sorted_msg.each{|m|

                    if  (t <=> m) > 0  # t is after time

                    else  # earlier
                        sorted_msg.insert(c1, t)
                        sorted_msg2.insert(c1,line)
                        inserted = true
                        # p "insert msg at #{c1}" if is_adm?(uid)
                        break
                    end
                    c1+=1
                }     
                if  !inserted
                    sorted_msg.push(t)
                    sorted_msg2.push(line)
                     # p "insert msg at end" if is_adm?(uid)
                end
            }
            __logf__

            # p "msg3=#{sorted_msg2.inspect}" if is_adm?(uid)
             @msg = sorted_msg2.join("<!--br-->")
            # p "msg2=#{@msg}" if is_adm?(uid)

            #if check_version(103)
                if args[:rm] && args[:rm].to_i == 1
                    # get room msg
                    room_msg = nil
                    # room = @player.room
                    # if room
                        # room_msg = get_room_msg(uid, room)
                        room_msg = MsgUtil.get_room_msg(uid)
                    # end

                    if room_msg
                        room_msg.strip!
                        if !check_version(105)
                            room_msg = room_msg.gsub("\"","'") # becuease client 1.0.4 has bug to call test2() in quest page
                        end
                         p "room_msg2:#{room_msg}"
                        @msg += "<rm>#{room_msg}</rm><!--br-->" if room_msg.size > 0
                    end
                end
            #end
            # p "LL-->#{@msg}"
            return @msg
            __logf__
    end

    def get
        # __h = SlowLog.in
          # p "++++++>start get: #{Time.now.to_f}"
        # return if !check_session or !user_data
          # p "++++++>done checksession: #{Time.now.to_f}"

        
        check_session_exist
        
        #print("uid=#{user_id}")
              
        _get(user_id, params)
                
       
        
                 # p "++++++>start render: #{Time.now.to_f}"       
        if @type2 == "text"        
            # p "msg2=#{@msg}"
            render :text=>@msg
        elsif @type2 == "json"
            ar = @msg.split("\n")
            ret = {
                # :t =>c[:time].to_i,
                :msg => ar
            }
            # p "==>11#{ret.to_json}"

            render :text=>ret.to_json       
        end
        
        __logf__
        
        # if !data
        #          data = {}
        #      end
        # data[:lastreadmsg] = c[:time].to_i
        # save_filedata(user_data[:id], data)
         # p "++++++>done get: #{Time.now.to_f}"
        # SlowLog.out(__h)
    end
    
    # def emote_list
    #     {
    #         "jump"=>["%s高兴的跳了起来","%s高兴的跳进%s的怀里"],
    #     }
    # end
=begin
$N : 自己的名字.
$n : 目标的名字.
$P : 自己的人称代名词.
$p : 目标的人称代名词.
$S : 对自己的称呼。
$s : 对自己的粗鲁称呼。
$C : 别人对自己的尊称。
$c : 别人对自己的粗鲁称呼。
$R : 对别人的尊称。
$r : 对别人的粗鲁称呼。\n");
=end
    def translate_emote(msg)
        p "-->translate_emote:#{msg}"
        ar = msg.split(' ')
        
        cmd = ar[0]
        # cmd = cmd[1..cmd.size-1]

        p_ar = [player[:name]].concat(ar[1..ar.size-1])
        p "cmd:#{cmd}, p_ar:#{p_ar.join(",")}"
        strs = emote_list[cmd]
        # p "strs:#{strs.values}"
        if strs
            # return strs[p_ar.size-1] % p_ar
            n_name = ""
            n_name = p_ar[1] if p_ar.size > 1
            if player['sex'] ==1
                _S = "在下"
                _s = "大爷"
            else
                _S = "小女子"
                _s = "老娘"
            end
            _c = _C = "心肝"
            _R= "大侠"
            _r = "恶贼"

            # s = strs.values[p_ar.size-1]
            s = [strs['others'], strs['others_target']]
            s = s[p_ar.size-1]
            p "s = #{s}"
            if s
                s = s.gsub("$N", player.name)
                p "s=#{s}, n=#{n_name}"
                s = s.gsub("$n", n_name)
                s = s.gsub("$P", "他").gsub("$p", "她")
                s = s.gsub("$s", _s).gsub("$S", _S).gsub("$C", _C).gsub("$c", _c).gsub("$R", _R).gsub("$r", _r)
            else
                s = ""
            end
            return s
        else
            # ar.delete_at(0)
            return ar.join(" ")
        end
        
        
    end
    def sendmsg
        p "headers: #{request.headers.inspect}"
        # get_session_id
        check_session_exist
        
        if player.name == nil
            p "user not in session"
            error("user not in session")
            return
        end
        # return if !check_session or !user_data
        # if !check_busy(5)
        #     error("You are busy!")
        #     return
        # end
        
        msg = params[:m]
        if !msg || msg.size > 100
            error("字数太多了")
            return
        end
        
        ch = params[:ch].to_i
        if !ch || ch < -1
            error("not allowed")
            return
        end
        
        if msg.index(/<|>|\\/) != nil
            error("文字中不能包含<>\\等字符！")
            return
        end
        # if msg=~/([a-zA-Z0-9]{6})/
        #      error("这里不能发布战队code")
        #      return
        # end        
        
        
        # canReply = true
        
        if msg[0..0] == '*'
            msg = translate_emote(msg.from(1).strip)
        else
            if ch > 0 #私聊
                msg2 = ""
                p2_name = get_username_by_id(ch)
                if p2
                    room_msg2 = "你对#{p2_name}说:#{msg}"
                    room_msg = "#{player.name}对#{p2_name}说:#{msg}"
                end
                msg = "#{player.name}对你说:#{msg}"
            elsif ch == 0
                # canReply = false
                room_msg = "#{player.name}说:#{msg}"
                msg = "你说:#{msg}"
            else # -1 => chat
                msg = "#{player.name}:#{msg}"
            end

        end


         # if canReply
         #     msg = "<span onclick='onreply(this);' id='#{player.id}@#{user_name}'>#{msg}</span>"
         # end         
          msg = msg.gsub("\n", "<br/>")
            p "send_msg:#{msg}"
             
        # msg = li(msg)
        roomid = params[:roomid]
        if ch == 0 
            if roomid
                MsgUtil.send_room_msg(user_id, roomid, msg)
                MsgUtil.send_msg_to_room(roomid, room_msg, player)
            end
            # send_msg_to_room(player.roomid, msg)
        elsif ch > 0
            MsgUtil.send_room_msg(user_id, roomid, li(room_msg2))
            MsgUtil.send_msg_to_room(roomid, li(room_msg), player)
            MsgUtil.send_msg(ch, msg)
        else
            MsgUtil.send_msg(ch, msg)
        end
        
        ret_msg = nil
        if params[:get] == "1"
            _get(user_id, params)
            # ret_msg = @msg.split("\n")
            ret_msg = @msg
        end
        
        p "sendmsg ok #{ret_msg}"
        success("ok",{:msg=>ret_msg})
        # render :json=>{:msg=>"ok"}
    end
    
    

end
