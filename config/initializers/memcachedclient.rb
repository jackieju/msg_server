require 'memcache.rb' #/usr/lib64/ruby/gems/1.8/gems/activesupport-2.3.5/lib/active_support/vendor/memcache-client-1.7.4/memcache.rb

require 'utility.rb'
require 'server_settings.rb'

mcd_default_options = {
        :namespace => 'msg:key',
        :memcache_server => "localhost:#{g_memcached_port}"
}

if (!$memcached)  
    $memcached= MemCache.new(mcd_default_options[:memcache_server], mcd_default_options)
end

p "==>memcached(#{$memcached.class}) all method:"+MemCache.instance_methods.inspect
print "==>memcached(#{$memcached.class}) all method:"+MemCache.instance_methods.inspect