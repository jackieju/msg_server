def read_banned_ip
    ips = read_file("/var/wh/banned_ip")
    if ips
        ar = ips.split("\n")
        banned_ips = []
        ar.each{|c|
            ip = c.strip
            banned_ips.push(ip)
        }
        return banned_ips
    end
    return []
end

def ban_ip_by_apache(ip)
    if $banned_ips && $banned_ips.include?(ip) == false
        $banned_ips.push(ip)
        $read_banip_time = Time.now.to_i
        
        append_file("/var/wh/banned-hosts", "#{ip} - ")
        append_file("/var/wh/banned_ip", "#{ip}")
    end
end