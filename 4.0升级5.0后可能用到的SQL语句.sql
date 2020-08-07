# set row_format=default
#解除items表上的外键约束c_items_1
alter table items
    drop foreign key c_items_1;
#删除items上的原有items_1索引
DROP INDEX items_1 ON items;
# 修改key_,从255->2048
#重新在items上创建items_1组合索引，指定key_长度为255
CREATE INDEX items_1 ON items (hostid, key_(255));
#重建items上的外键约束c_items_1
alter table items
    add constraint c_items_1
        foreign key (hostid) references hosts (hostid)
            on delete cascade;

#