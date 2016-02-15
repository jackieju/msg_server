def encode_uid_key(uid, key)      
    efi = (uid.to_i<<2)^(key.to_i<<2)
    return efi
end

def decode_uid_key(key, efi)
    
    uid = (efi.to_i ^ (key.to_i<<2))>> 2
    return uid
end



# test 
key = rand(1000000)
uid = 216767
efi = encode_uid_key(uid, key)
p "efi: #{efi}, key:#{key}, uid:#{uid}"

p decode_uid_key(key, efi)
