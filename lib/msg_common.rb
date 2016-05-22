# receive key and user info
def receive_info(params)
    key = params[:k]
    uid = params[:u]
    n = params[:n]
    ch= params[:ch]
    sex = params[:sex]
    if !key || !uid || !n
        return "error params"
    end
    
    # save it to memcached
    $memcached.set(key, {
        :u=>uid
    })
    p "added session with key #{key}"
    
    # delete old mkey
    hash = $memcached.get("user_#{uid}")
    if hash && hash[:mkey]
        $memcached.delete(hash[:mkey])
    end
    $memcached.set("user_#{uid}", {
        :name=>n,
        :mkey=>key,
        :ch=>ch,
        :sex=>sex
    })
    p "added user user_#{uid}"
    log_msg("add user #{uid}(#{key}) to memcached", "gserver")
    return "OK"
end