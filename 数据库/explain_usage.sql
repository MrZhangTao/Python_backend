use java;
create table user_info (
	id bigint(20) not null auto_increment,
    name varchar(50) not null default '',
    age int(11) default null,
    primary key(id),
    key name_index (name)
) engine=InnoDB default charset=utf8;


create table order_info (
	id bigint(20) not null auto_increment,
    user_id bigint(20) default null,
    product_name varchar(50) not null default '',
    productor varchar(30) default null,
    primary key(id),
    key user_product_detail_index(user_id, product_name, productor)
) engine=InnoDB default charset=utf8;
#----------------------------
select * from user_info where id = 2;

SELECT 
    *
FROM
    user_info
WHERE
    id IN (1 , 2, 3) 
UNION SELECT 
    *
FROM
    user_info
WHERE
    id IN (3 , 4, 5) 
UNION SELECT 
    *
FROM
    user_info
WHERE
    id IN (6 , 7);

#-------------------------------

select * from user_info, order_info where user_info.id = order_info.user_id;

#--------------------

select * from user_info, order_info where user_info.id = order_info.user_id and order_info.user_id = 5;

#--------------------
select * from user_info;
select * from user_info where id <> 1;
select * from user_info where id not in (2, 3);
select * from user_info where name like 'xys';
select * from user_info where name is null;

#---------------------
select * from order_info;

select * from order_info where id = 4 and user_id = 2 and product_name = 'p1' and productor= 'WHH';
select * from order_info where user_id = 2 and product_name='p1' and productor= 'WHH';

#------------------
select * from order_info order by product_name;
select * from order_info order by user_id, product_name;

#--------------------
select * from order_info where user_id = 1 and product_name like '%1%';
select * from order_info where user_id = 1 and product_name like '_1%';
select * from order_info where user_id = 1 and product_name like 'p1%';

select * from order_info where user_id = 1 and product_name <> 'p2' and productor = 'WHH';
select * from order_info where user_id = 1 and product_name not in ('p2') and productor = 'WHH';
select * from order_info where user_id = 1 and product_name = 'p1' and productor not in ('WHHs');

select * from order_info where user_id  is not null and product_name is not null and productor = 'WHH';
select * from order_info where user_id  is null and product_name is not null and productor = 'WHH';
