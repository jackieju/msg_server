require 'msg.rb'

JU::Msg.reset
JU::Msg.init("/var/wh/message")
JU::Msg.add_channel("chat", -1, "闲聊", 300, true, true)
JU::Msg.add_channel("rumor", -2, "江湖传闻", 3600*24, true, true)
JU::Msg.add_channel("sys", -3, "公告", 3600*24, true, true)
JU::Msg.add_channel("tianshi", -4, "天时", 60, true, true)
JU::Msg.add_channel("wldh", -5, "武林大会", 3600*24, true, true)
JU::Msg.add_channel("bwxy", -6, "保卫襄阳", 300, true, true)
JU::Msg.add_channel("bh", -7, "帮会门派", 3600, true, true)

p "init msg ok.#{$$} fs=#{JU::Msg.fs_root}"
print "init msg ok. fs=#{JU::Msg.fs_root}\n"
p "#{JU::Msg.all_channels.inspect}\n"
print "#{JU::Msg.all_channels.inspect}\n"