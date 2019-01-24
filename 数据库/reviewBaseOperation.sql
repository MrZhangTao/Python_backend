mysql -u root -p
create database dbname;
drop database dbname;
show databases;

-- information_schema数据库又称为信息架构，数据表保存了MySQL服务器所有数据的信息。
-- performance_schema数据库主要用于收集数据库服务器性能参数，以便优化mysql数据库性能。
-- mysql数据库存储着与MySQL运行相关的基本信息

create database debug;
show databases;
show tables;

create table items(
    id int(11) not null auto_increment,
    name varchar(32) not null comment "商品名称",
    price float(10, 1) not null comment "商品定价",
    detail text comment "商品描述",
    pic varchar(64) default null comment "商品图片",
    createtime datetime not null comment "生产日期",
    primary key("id")
) engine=innodb default charset=utf-8;

-- innodb是具备事务功能的引擎
constraint FK_orders_id foreign key("user_id") references user("id")
on delete no action on update no action;
-- constraint symbol --指明约束符
-- restrict noaction cascade set null

tinyint smallint mediumint int bigint float(n, m), double(n, m), decimal(n, m);

insert into tabname(col1, col2, ...clom) values(val1, val2, ...valm);
update tabname set col1 = val1[, col2=val2] where condition;
delete from tabname where condition;
select * from tabnamel;

insert into user(id, username, birthday, sex, address)
values("3", "new data", "2004-02-21", 1, "exit");

update user set username="Faker" where work="lol" and rankid=1;
delete from user where rankid <> 1;

-- 范围比较符：< > <= >= between and,like(in不是)

concat(s1,s2,s3...)

alter table tabname modify ...
alter table tabname add ...
alter table tabname change ...
alter table tabname drop ...

alter table tabname add colname coltype;
alter table tabname add age int(3) first;
alter table tabname add xingbie char(1) after age;
alter table tabname modify xingbie char(4);
alter table tabname add change xingbie sex char(4) first;
create table tabname select * from oldtab;
create table tabname like oldtab;--只是复制表结构，不会复制数据

--视图中不能使用索引，也不能使用触发器(这就很局限了，可能生产中能使用视图的地方并不多)
--视图中可以使用order by,但是从视图检索数据时，也包含了order by,则内部的order by会被覆盖。(所以内部还是不要用了,没必要)

create index indexname on tabname(index_col_name);
alter table tabname add index on (index_col_name);

create table tabname(
    id int(11) not null auto_increment,
    index index_id (id)
)engine=innodb charset=utf-8 auto_increment=1;

show index from tabname [\G]; -- \G代表优化显示方式(命令行中使用)

drop index index_name on tabname;

create unique index index_name on tabname(index_col_name[,...])
create primary key on tabname(index[,...])
alter table tabname add unique index index_name on (index_col_name[(len),...])
alter table tabname add primary key on (index_col_name[(len),...])

count(distinct col) / count(*)

delimiter $$
drop procedure if exists sp_sc$$
create procedure sp_sc(out val1 varchar(3), out val2 int(3))
begin
	select if(val1, "has val", "is null"), val2;
    if val1 is null and val2 is null then
		select max(score) into val2 from sc;
		select sid from sc limit 1 into val1;
		select "aaaa";
	elseif val1 <> "01" and val2 <> 99 then
		select max(score) into val2 from sc;
		select sid from sc limit 1 into val1;
        select "ssss";
    else
		select max(score) into val2 from sc;
		select sid from sc limit 1 into val1;
        select @val2 := @val2 + 1000;
        select @val2;
    end if;
end$$
delimiter ;
call sp_sc(@val1, @val2);
select @val1, @val2;

delimiter ??
drop procedure if exists sp_case_test??
create procedure sp_case_test(in val1 int(1), out retval int(11))
begin
	case val1
		when 1 then select 1000 into retval;
        when 2 then select 2000 into retval;
        else set retval = 9999;
	end case;
end??
delimiter ;
call sp_case_test(22, @retvalue);
select @retvalue;

delimiter >>
drop procedure if exists sp_repeat_test>>
create procedure sp_repeat_test(in val1 int(1), out retval int(11))
begin
	declare n int;
    set n = 0;
    repeat
		set n = n + 1;
	until n = 10 end repeat;
    while n < 100 do
		set n = n + 10;
	end while;
    set retval = n;
end>>
delimiter ;
call sp_repeat_test(1, @retval22);
select @retval22;

create function func_name ([param1 type][param2 type]) returns ret_type
begin
    return ret_val
end

delimiter //
create trigger trigger_name (before|after)
(insert|update|delete) on tabname
for each row
begin
    trigger_body;
end//
delimiter ;
-- relational trigger record: old, new

-- start transaction  begin   commit   rollback    savepoint name & rollback to savepoint name
-- undo、redo日志 的作用
-- 事务 隔离级别(分离水平)  乐观锁  悲观锁  共享锁定  排它锁定

