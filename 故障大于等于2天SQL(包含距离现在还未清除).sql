# 指定时间段内，已经处理完毕的
select distinct aaa.eventid ,#事件id
aaa.eventname as 故障标题 ,
aaa.hostgroupname as 业务系统名称,
aaa.hostname as 设备名称, # 主机名称
aaa.ipad as 设备IP地址,# IP地址
aaa.activetime as 故障发生时间, #发生时间
aaa.cleartime as 故障清除时间,  #清除时间
format(aaa.num/60/60/24,2) as 故障清除历时（天）
from (
select e.eventid as eventid, 
e.objectid,
e.name as eventname,
h.name as hostname,
h.host as ipad,
hgp.name as hostgroupname,
FROM_UNIXTIME(e.clock,'%Y-%m-%d %H:%i:%s') as activetime,
(select FROM_UNIXTIME(e.clock,'%Y-%m-%d %H:%i:%s') from events e where e.eventid = er.r_eventid) as cleartime ,
((select e.clock from events e where e.eventid = er.r_eventid) - e.clock )  as num # 单位是秒
from events e ,event_recovery er ,triggers tr , functions f , hosts h , items i ,hstgrp hgp,hosts_groups hg
where  e.object = 0 and source = 0
and e.eventid = er.eventid
and e.objectid = tr.triggerid
and f.triggerid = tr.triggerid
and f.itemid = i.itemid
and h.hostid = i.hostid 
and h.hostid = hg.hostid
and hg.groupid = hgp.groupid
and tr.status = 0 # 选择触发器为启用状态产生的告警
and i.status = 0  # 选择主机为启用状态产生的告警
and h.status <>3  # 去掉zabbix模板类，模板和主机共存一张表
#and h.host<>'Zabbix server' # 去掉zabbix server本身告警
and ((select e.clock from events e where e.eventid = er.r_eventid) - e.clock ) > 172800 # 清除时间-发生时间大于2天
#and e.clock >1590940800 and e.clock <1593532799 # unix时间转换，查6月1日-6月30日
order by e.clock) aaa

union 

#指定时间段内，距离当前时间还没处理完成的
select distinct bbb.eventid,
bbb.eventname as 故障标题 ,
bbb.hostgroupname as 业务系统名称,
bbb.hostname as 设备名称, # 主机名称
bbb.ipad as 设备IP地址,# IP地址
bbb.activetime as 故障发生时间, #发生时间
bbb.cleartime as 故障清除时间,  #清除时间
format(bbb.num/60/60/24,2) as 故障清除历时（天）
from (
select p.eventid,
p.objectid, 
p.name eventname,
h.name as hostname,
h.host as ipad,
hgp.name as hostgroupname,
FROM_UNIXTIME(p.clock,'%Y-%m-%d %H:%i:%s') as activetime,
sysdate() as cleartime,
UNIX_TIMESTAMP(sysdate()) - p.clock as num
from problem p ,triggers tr , functions f , hosts h , items i ,hstgrp hgp,hosts_groups hg
where p.source = 0 and p.object = 0
and p.objectid = tr.triggerid
and f.triggerid = tr.triggerid
and f.itemid = i.itemid
and h.hostid = i.hostid 
and h.hostid = hg.hostid
and hg.groupid = hgp.groupid
and p.r_eventid is null
and tr.status = 0 # 选择触发器为启用状态产生的告警
and i.status = 0  # 选择主机为启用状态产生的告警
and h.status <>3  # 去掉zabbix模板类，模板和主机共存一张表
#and h.host<>'Zabbix server'  # 去掉zabbix server本身告警
and (UNIX_TIMESTAMP(sysdate()) - p.clock)  > 172800 # 清除时间-发生时间大于2天
#and p.clock >1590940800 and p.clock <1593532799 # unix时间转换，查6月1日-6月30日
order by p.clock) bbb