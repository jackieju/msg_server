# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'utility.rb'
require 'server_settings.rb'
require 'mycrpt.rb'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  after_filter :post_action
  before_filter :pre_action
   
  def cors_preflight_check
      p "def cors_preflight_check:#{request.method}"
      cors_set_headers
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE, PATCH'
      response.headers['Access-Control-Allow-Headers'] = 'X-MKEY, X-EFI, X-Requested-With, Content-Type, Accept, tenant-id'
      response.headers['Access-Control-Max-Age'] = '1728000'
    if request.method.to_s.downcase == 'options'
        p "==>cors_preflight_check"
      #   
      # response.headers['Access-Control-Allow-Origin'] = '*'
      # response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE, PATCH'
      # response.headers['Access-Control-Allow-Headers'] = 'X-MKEY, X-EFI, X-Requested-With, Content-Type, Accept, tenant-id'
      # response.headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end
 
  def cors_set_headers
    headers['Access-Controll-Allow-Origin'] = '*'
    headers['Access-Controll-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE, PATCH'
    headers['Access-Controll-Allow-Headers'] = 'X-MKEY, X-EFI, X-Requested-With, Content-Type, Accept, tenant-id'
    headers['Access-Controll-Max-Age'] = '1728000'
    p "==>cors_set_headers"
  
  end
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def error(msg, data=nil)
       ret = {
          "error"=>msg
      }
      ret = ret.merge(data) if data
      render :text=>ret.to_json
      # render :text=>"{\"error\":\"#{msg}\"}"
  end
  def success(msg="OK", data=nil)
      ret = {
          "OK"=>msg
      }
      ret = ret.merge(data) if data
      render :text=>ret.to_json
      
  end
  ### for session check ###
  
  def check_banned_ip
      time = Time.now
      # check ip
      $read_banip_time = 0 if !$read_banip_time 
      if $banned_ips == nil ||  time.to_i - $read_banip_time > 60
          $banned_ips = read_banned_ip
          $read_banip_time = time.to_i
      end
      
      if $banned_ips.include?(request.remote_ip)
        
              raise Exception.new("Denied")
          
      end
      
  end
  def device
      
      @device = @device_string = cookies[:d]
      if (cookies[:d])
      
          cookies[:d] = {
              :value=>cookies[:d],
                :expires => 1.year.from_now,
                :domain => request.host
          }
      end
      if check_version(108)
          # cookies[:d]
          if @device_string
              # parse device string uuid@time|device_token#devicetype
              i = @device_string.index("@")
              if i&&i >=0
                  @device_uuid=@device_string[0..i]
                  s2 = @device_string[i+1..@device_string.size-1]
                  
                  # s=>time|device_token#devicetype
                  # search device token
                  i2 = s2.index("|")
                  if i2 >=0 
                      @device_timestamp = s2[0..i2]
                      s2 = s2[i2+1..s2.size-1]
                      # s2=>device_token#devicetype
                      
                      i2 = s2.index("#")
                      if i2 >=0
                          @device_token = s2[0..i2-1]
                          @device_type = s2[i2+1..s2.size-1]
                          # print "device_type:#{@device_type},  #{@device_type[0..0]}, #{@device_type[1..1]}\n"
                  
                          if @device_type[0..0]=="i" && @device_type[1..1] == "P"
                              if @device_type[2..2] == "h" || @device_type[2..2] == "o"
                                  @device1 = "iPhone"
                                  @device2 = @device_type[6..@device_type.size-1].gsub(",", ".").to_f
                                  if @device2 < 5
                                      @device = "i3"
                                  else
                                      @device = "r4"
                                  end
                              else
                                  @device = "pd"
                                  @device1 = "iPad"
                                  @device2 = @device_type[4..@device_type.size-1].gsub(",", ".").to_f
                          
                              end
                          else
                              @device1=""
                              @device2=0
                              @device="r4"
                          end
                      end
                  end
              end
          end
      end # if check_version
  
       return @device
  end
  def pre_action
     
      # @__t = Time.now.to_f
      # $slow_log = SlowLog.in
      # __logf_start__ if @logf
      __logf_start__
      
      time = Time.now
      
      check_banned_ip()
      
      device 
      
      $quest_context = nil
      $uid = nil
      st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"
      print("#{$$}[#{st}]request(from #{request.remote_ip}:#{@device_string}|#{@device}|#{@device1}|#{@device2}|#{@device_token}:v#{version}): #{request.request_uri}, #{request.params.inspect}\n")
      
      $request_count +=1
      if (params[:uid] && params[:uid] != "")
          $uid=params[:uid]
      elsif session[:uid]
          $uid = session[:uid]
      end
      
      p "cookie:#{cookies.inspect}"
      p "session:#{session.inspect}"
      # __logf("#{request.class.instance_methods.inspect}")
      __logf("request: #{request.request_uri}, #{request.params.inspect}")
      p "=>pre_action done"
  end
  
  def post_action
      $uid = nil
      $player = nil
      #$username = nil
      # if @__t != nil
      #     span = Time.now.to_f - @__t
      #     if span > 1
      #         log_msg("Slow request #{span}s, #{request.inspect}", "PERFORMANCE")
      #     end
      # end
      # SlowLog.out($slow_log) if $slow_log 
      __logf_end__
  end
  def version
      #debug
      # if params[:v]
      #     @version = params[:v]
      #     cookies[:v] = {
      #         :value=>@version,
      #           :expires => 1.year.from_now,
      #           :domain => request.host
      #     }
      #     return @version
      # end
      #debug end
      @version = cookies[:v]
      if (cookies[:v])
      
          cookies[:v] = {
              :value=>cookies[:v],
                :expires => 1.year.from_now,
                :domain => request.host
          }
      end
      # cookies[:d]
  
       return @version
   end

   def player
       if $player 
           return $player
       else
           $player = $memcached.get("user_#{user_id}")
           p "===>player:#{$player.inspect}"
           return $player
       end
   end
   def user_id
       p "==>cookie: #{cookies.inspect}, session #{session.inspect}"
       
       p "uid:#{$uid}, session uid:#{session[:uid]}"
       return $uid if $uid
       $uid = session[:uid]
       return $uid
   end
   

   

   
       # get_session_id with query db or fs
       def get_session_id
            p "==>cookie: #{cookies.inspect}"
            p "===>session id=#{session[:sid]} session uid = #{session[:uid]}"
            p "cookies[:_wh_session] = #{cookies[:_wh_session] }"

           if cookies[:_wh_session] 
                session[:uid] = nil if session[:sid] !=  session[:sid]
                session[:sid] = cookies[:_wh_session]       
            end
                 # 
                 # after uesr first register, the _wh_session will be set in user's cookie
                 # which will send by all afteraward quest
                 #
                 if (params[:sid])
                #     reset_session

              #  p request.host
            #    p "====>>>>dda29"
                # set cookie first, because this is used to generate sid when write memcached
                    if cookies[:_wh_session] == nil or cookies[:_wh_session] != params[:sid] # first time, or manually change session to other session

                        cookies[:_wh_session] = {
                            :value => params[:sid],
                            :expires => 1.year.from_now,
                            :domain => request.host
                        }
                        session[:uid] = nil
                    end
                 #   p "====>>>>dda69"+params[:sid]
                #    p "====>>>>dda79"+session[:sid]
                     if (session[:sid] == nil || params[:sid] != session[:sid] )
                         session[:sid] = params[:sid]
                         session[:uid] = nil
                      end

                     # @sid = params[:sid]

                    # cookies[:_wh_session] = params[:sid]
                 #   p "====>>>>dda39"
                 else
                 #    p "====>>>>dda19"
                     if !session[:sid]
                         sid = cookies[:_wh_session]
                         if sid ==nil
                             sid = params[:sid] # for dev
                             if !sid
                                 # error("session not exist, please restart app")
                                 return nil
                             end
                         end  
                         session[:sid] = sid
                         session[:uid] = nil
                     end
                 end
                # p "====>>>>dda9"
           return session[:sid]
       end

  
       # return true if version >= v
       def check_version(v)
           return true if (!version || version[0..4].gsub(".","").to_i>=v)
           return false
       end
end
