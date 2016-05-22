# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

#
# 每天切分一次日志文件
#

# config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}#{Date.today.to_s}.log", "daily")
#按日志文件大小切分,每50M切分一次（即每50M时轮换一次）
config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}1.log", 2, 51200000*2)

#必须加这一句，不然会以debug模式打印日志
 config.logger.level = Logger::INFO 
 config.logger.level = Logger::DEBUG    
   
#！注意： config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}1.log", 2, 51200000)  中
#{Rails.env}1.log  这句代码，即找到当前启动模式的日志文件，若写成#{Rails.env}.log时，会报错，提示无权限修改