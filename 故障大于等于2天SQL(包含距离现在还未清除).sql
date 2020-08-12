# ָ��ʱ����ڣ��Ѿ�������ϵ�
select distinct aaa.eventid ,#�¼�id
aaa.eventname as ���ϱ��� ,
aaa.hostgroupname as ҵ��ϵͳ����,
aaa.hostname as �豸����, # ��������
aaa.ipad as �豸IP��ַ,# IP��ַ
aaa.activetime as ���Ϸ���ʱ��, #����ʱ��
aaa.cleartime as �������ʱ��,  #���ʱ��
format(aaa.num/60/60/24,2) as ���������ʱ���죩
from (
select e.eventid as eventid, 
e.objectid,
e.name as eventname,
h.name as hostname,
h.host as ipad,
hgp.name as hostgroupname,
FROM_UNIXTIME(e.clock,'%Y-%m-%d %H:%i:%s') as activetime,
(select FROM_UNIXTIME(e.clock,'%Y-%m-%d %H:%i:%s') from events e where e.eventid = er.r_eventid) as cleartime ,
((select e.clock from events e where e.eventid = er.r_eventid) - e.clock )  as num # ��λ����
from events e ,event_recovery er ,triggers tr , functions f , hosts h , items i ,hstgrp hgp,hosts_groups hg
where  e.object = 0 and source = 0
and e.eventid = er.eventid
and e.objectid = tr.triggerid
and f.triggerid = tr.triggerid
and f.itemid = i.itemid
and h.hostid = i.hostid 
and h.hostid = hg.hostid
and hg.groupid = hgp.groupid
and tr.status = 0 # ѡ�񴥷���Ϊ����״̬�����ĸ澯
and i.status = 0  # ѡ������Ϊ����״̬�����ĸ澯
and h.status <>3  # ȥ��zabbixģ���࣬ģ�����������һ�ű�
#and h.host<>'Zabbix server' # ȥ��zabbix server����澯
and ((select e.clock from events e where e.eventid = er.r_eventid) - e.clock ) > 172800 # ���ʱ��-����ʱ�����2��
#and e.clock >1590940800 and e.clock <1593532799 # unixʱ��ת������6��1��-6��30��
order by e.clock) aaa

union 

#ָ��ʱ����ڣ����뵱ǰʱ�仹û������ɵ�
select distinct bbb.eventid,
bbb.eventname as ���ϱ��� ,
bbb.hostgroupname as ҵ��ϵͳ����,
bbb.hostname as �豸����, # ��������
bbb.ipad as �豸IP��ַ,# IP��ַ
bbb.activetime as ���Ϸ���ʱ��, #����ʱ��
bbb.cleartime as �������ʱ��,  #���ʱ��
format(bbb.num/60/60/24,2) as ���������ʱ���죩
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
and tr.status = 0 # ѡ�񴥷���Ϊ����״̬�����ĸ澯
and i.status = 0  # ѡ������Ϊ����״̬�����ĸ澯
and h.status <>3  # ȥ��zabbixģ���࣬ģ�����������һ�ű�
#and h.host<>'Zabbix server'  # ȥ��zabbix server����澯
and (UNIX_TIMESTAMP(sysdate()) - p.clock)  > 172800 # ���ʱ��-����ʱ�����2��
#and p.clock >1590940800 and p.clock <1593532799 # unixʱ��ת������6��1��-6��30��
order by p.clock) bbb