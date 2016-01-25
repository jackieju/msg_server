class MsgController < ApplicationController
    ### api ###
    # 
     before_filter :check_ip
     
     def check_ip
        if (request.remote_ip != g_valid_msg_client_ip)
            raise Exception.new("Denied")
        end
    end
     
    def send_msg#(ch, m, type='')
        ch = params[:ch]
        m = params[:m]
        type = params[:type]
        type = "" if !type
        MsgUtil.send_msg(ch, m, type) 
    end
    
    #def send_msg_to_room(r, m, p=nil)
    def send_room_msg
        r = params[:r]
        m = params[:m]
        p = params[:p]
        MsgUtil.send_msg_to_room(r, m, p)
    end
    
    #def clear_room_msg(uid)
    def clear_room_msg
         MsgUtil.clear_room_msg(params[:uid])
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
