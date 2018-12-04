require 'msg.rb'

JU::Msg.reset("xkx")
JU::Msg.init("xkx", "/var/wh/message")
JU::Msg.add_channel("xkx", "chat", -1, "闲聊", "c", 300, true, true)
JU::Msg.add_channel("xkx", "rumor", -2, "江湖传闻", "r", 3600*24, true, true)
JU::Msg.add_channel("xkx", "sys", -3, "公告", "s", 3600*24, true, true)
JU::Msg.add_channel("xkx", "tianshi", -4, "天时", "t", 60, true, true)
JU::Msg.add_channel("xkx", "wldh", -5, "武林大会", "w", 3600*24, true, true)
JU::Msg.add_channel("xkx", "bwxy", -6, "保卫襄阳", "b", 300, true, true)
JU::Msg.add_channel("xkx", "bh", -7, "帮会门派", "h", 3600, true, true)



JU::Msg.reset("xy")
JU::Msg.init("xy", "/var/xy/message")
JU::Msg.add_channel("xy", "chat", -1, "闲聊", "c", 300, true, true)
JU::Msg.add_channel("xy", "rumor", -2, "江湖传闻", "r", 3600*24, true, true)
JU::Msg.add_channel("xy", "sys", -3, "公告", "s", 3600*24, true, true)
JU::Msg.add_channel("xy", "tianshi", -4, "天时", "t", 60, true, true)

$client_list=["xkx", "xy"]


p "init msg ok.#{$$} fs=#{JU::Msg.fs_root('xkx')}"
print "init msg ok. fs=#{JU::Msg.fs_root('xkx')}\n"
p "#{JU::Msg.all_channels('xkx').inspect}\n"
print "#{JU::Msg.all_channels('xkx').inspect}\n"