require 'ban_ip.rb'
require 'util_msg.rb'
require 'hash.rb'

def preload_models_in_rails()  
    log "[[[>>>>>preload_modules in #{File.dirname(__FILE__)}<<<<<]]\n", 6
    # t = Time.now.to_f
    count = 0
    # p "#{File.dirname(__FILE__)}/lib/**/*.rb"
    # path = "#{File.dirname(__FILE__)}/../../lib/**/*.rb" # in application_controller
    path = "#{File.dirname(__FILE__)}/**/*.rb"   # in utility.rb
    load("objects/object.rb")
    load("objects/npc/npc.rb")
    load("objects/npc/hero/hero.rb")
    Dir[path].each { |f|
        # next if f.end_with?(".rb") == false
        # log "loading #{f}"
        next if f.end_with?("log.rb")
        load(f)
        count +=1
     }
     Userext
     Usereq
     Userskill
     Userquest
     Userrsch
     Battle
     Equipment
     Skill
     Team
     Tradable
     Skill
     Game::Skill
     Unarmed
     Dodge
     Parry
     Daofa
     Fencing
     Huyuezhan
     Jiuguishengzhuan
     Konglingjian
     Qishangquan
     Yidaoliu
     Liefengdaofa
     # Ring
     # Blade
      # p "preload_models costs #{Time.now.to_f- t}"
      p "preload #{count} files"
      puts "\npreload #{count} files\n"
      
end

def user_id
    $uid
end

def user_name
    $username
end