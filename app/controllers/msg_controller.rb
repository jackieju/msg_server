require 'msg_common.rb'

class MsgController < ApplicationController
    ### api ###
    # 
     before_filter :check_ip
     
     # def test
     #        session[:test] = 1000
     #        
     #    end
     #    def test2
     #        p "cookie:#{cookies.inspect}"
     #        render :text=>session[:test]
     #    end
     def check_ip
        if (request.remote_ip != g_valid_msg_client_ip)
            raise Exception.new("Denied")
        end
    end
    # receive key
    def k
        key = params[:k]
        uid = params[:u]
        n = params[:n]
        ch= params[:ch]
        sex = params[:sex]
        if !key || !uid || !n
            error("error params")
            return
        end
        
       receive_info(params)
        
        success
    end
    def send_msg#(ch, m, type='')
        ch = params[:ch]
        m = params[:m]
        type = params[:type]
        type = "" if !type
        MsgUtil.send_msg(ch, m, type) 
        success()
    end
    
    #def send_msg_to_room(r, m, p=nil)
    def send_room_msg
        r = params[:r]
        m = params[:m]
        u = params[:u]
        MsgUtil.send_room_msg(u, r, m)
        success()
    end
    
    #def clear_room_msg(uid)
    def clear_room_msg
         MsgUtil.clear_room_msg(params[:uid])
         success()
    end
    
    #def get_room_msg(uid)
    # def get_room_msg
    #     MsgUtil.get_room_msg(params[:uid])
    # end
    #def delete_msg(ch)
    def delete_msg()
        MsgUtil.delete_msg(params[:ch])
    end
    def send_raw_msg(m)
        MsgUtil.send_raw_msg(params[:m])
    end
end
