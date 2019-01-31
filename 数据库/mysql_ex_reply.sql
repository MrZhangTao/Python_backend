use workman;

-- student; sid, sname, sage(datetime), ssex    学生表
-- 			sc:  sid,   cid, score              成绩表
-- 	course: cid, cname, tid                     课程表
-- teacher: tid tname                           教师表

## 练习题目
-- 1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
select s.*, a.score as score_01, b.score as score_02 from student as s,
(select sid, score from sc where cid = "01") as a,
(select sid, score from sc where cid = "02") as b
where a.score > b.score and a.sid = b.sid and a.sid = s.sid; -- 把01课程的成绩和02课程的成绩筛选出来，然后再联结

-- 1.1 查询同时参加了" 01 "课程和" 02 "课程的学生
select s.*, sc1.score as score_01, sc2.score as score_02 from student as s,
(select sid, score from sc where cid = "01") as sc1,
(select sid, score from sc where cid = "02") as sc2
where sc1.sid = sc2.sid and sc1.sid = s.sid; -- 在上一则查询的基础上，减去比较条件

-- 1.2 查询参加了" 01 "课程但可能未参加" 02 "课程的学生(未参加时显示为 null )
select s.*, sc1.score as score_01, sc2.score as score_02 from student as s
left join (select sid, score from sc where cid = "01") as sc1 on sc1.sid = s.sid 
left join (select sid, score from sc where cid = "02") as sc2
on sc1.sid = sc2.sid; -- 在上一则查询的基础上，使用左联结代替

-- 1.3 查询未参加" 01 "课程但参加了" 02 "课程的学生
select s.* from student as s, 
(select sid, min(cid) as min_cid from sc group by sid having min_cid = "02") as tempsc
where s.sid = tempsc.sid; -- 计算课程id的最小值，需为02

-- 2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select s.sid, s.sname, sc.avg_score from student as s,
(select sid, avg(score) as avg_score from sc group by sid having avg_score > 60) as sc
where s.sid = sc.sid; -- 先筛选出平均分大于60的所有学生id级平均分，再联结

-- 3. 查询在 SC 表存在成绩的学生信息
select s.* from student as s where exists (select 1 from sc where sid = s.sid); -- 存在判断

select distinct student.* from student, sc where student.sid = sc.sid; -- 联结去重

-- 4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
select s.sid, s.sname, tempsc.totalsc, tempsc.sumscore from student as s left join
(select sid, count(cid) as totalsc, sum(score) as sumscore from sc group by sid) as tempsc
on s.sid = tempsc.sid; -- 先处理sc表计算出需要的字段，再左联结进行整理

-- 4.1 查有成绩的学生信息
select s.* from student as s right join (select sid, sum(score) as sumscore from sc group by sid) as tempsc
on s.sid = tempsc.sid and tempsc.sumscore > 0; -- 总成绩肯定大于0

select * from student where exists (select 1 from sc where student.sid = sid); -- 在sc表中的sid即为有成绩的学生

-- 5. 查询「李」姓老师的数量
select count(tid) as num from teacher where tname like "李%";

select count(tid) as num from teacher where tname regexp "^李";

-- 5.1 查询「李」姓学生的数量
select count(sid) as num from student where sname like "李%"; -- 通配符匹配

select count(sid) as num from student where sname regexp "^李"; -- 正则匹配

-- 6. 查询学过「张三」老师授课的同学的信息 
-- (需要使用到4张表)
select s.*, sc.cid, t.tid, t.tname from student as s, sc, course, teacher as t where
s.sid = sc.sid and sc.cid = course.cid and course.tid = t.tid and t.tname = "张三";

-- 7. 查询没有学全所有课程的同学的信息 
select s.* from student as s,
(select sid, count(cid) as num from sc group by sid having num < (select count(cid) from course)) as tempsc
where s.sid = tempsc.sid; 
-- 但这种解法得出来的结果不包括什么课都没选的同学 --
-- 下面的这种解法考虑了没选课的情况 --
select s.*, tempsc.num from student as s left join
(select sid, count(cid) as num from sc group by sid) as tempsc
on s.sid = tempsc.sid where (tempsc.num is null or (tempsc.num < (select count(cid) from course))); 

-- 8. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息 
select distinct student.* from student, sc as outsc
where outsc.sid = student.sid and 
exists(select sc.cid from sc where sc.sid = "01" and sc.cid = outsc.cid); -- 先找出01同学所学的所有课程

-- 9. 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息 
-- 思路：1.首先交叉联结，假设所有的学生都有数量相同的课程
--            2.然后联结的结果继续与sc左联结，目的是可以筛选出那些实际上未选择某课程的学生id
--            3.内联结student以此获取满足要求的学员数据
-- select student.sid, t.cid from student, (select cid from sc where sid = "01") as t;
-- select t2.sid sc.sid, sc.cid from (select student.sid, t.cid from student, (select cid from sc where sid = "01") as t) as t2 left join sc on t2.sid = sc.sid and t2.cid = sc.cid where sc.sid is null
select * from student where sid not in(
select t2.sid from (select student.sid, t.cid from student, (select cid from sc where sid = "01") as t)
as t2 left join sc on t2.sid = sc.sid and t2.cid = sc.cid where sc.sid is null) and sid != "01";
-- 1 1    1 1
-- 1 2    1 null
-- 1 3    1 3
-- 叠合，所以右侧是不符合要求的

-- 10. 查询没学过"张三"老师讲授的任一门课程的学生姓名 
-- 思路：1.张三老师讲授的所有课程
--      2.学过张三老师课的学生，然后取反
select student.sid from student where student.sid not in (
    select sid from sc where exists(
        select 1 from course, teacher where teacher.tname = "张三" and teacher.tid = course.tid and course.cid = sc.cid
    )
);

-- 11. 查询两门及以上不及格课程的同学的学号，姓名及其平均成绩 
select student.sid, student.sname, t2.avg_score from student,                  -- 提供对应的姓名
(select sid from sc where score < 60 group by sid having count(cid) > 1) as t, -- 提供符合要求的同学sid
(select sid, avg(score) as avg_score from sc group by sid) as t2               -- 提供对应的平均成绩
where student.sid = t.sid and t.sid = t2.sid;

-- 12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select student.*, sc.score from student, sc where sc.sid = student.sid and sc.cid = "01" and sc.score < 60 order by sc.score desc;

-- 13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select sid, sum(score) as sum_score, avg(score) as avg_score from sc group by sid order by sum_score desc, avg_score desc;

-- 14. 查询各科成绩最高分、最低分和平均分：
--     以如下形式显示：课程 ID，课程 name，选修人数 num, 最高分，最低分，平均分，及格率，中等率，优良率，优秀率
--     及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
--     查询结果按人数降序排列，若人数相同，按课程号升序排列
-- 思路：使用case语句 将分组后的每条记录的分数转为 1 or 0,再使用sum求和
select course.cname, std_sc_situation.* from
(select cid, count(sid) as num, max(score), min(score), avg(score),
sum(case when score >= 60 then 1 else 0 end) / count(sid) as rate_60,
sum(case when score >= 70 and score < 80 then 1 else 0 end) / count(sid) as rate_70,
sum(case when score >= 80 and score < 90 then 1 else 0 end) / count(sid) as rate_80,
sum(case when score >= 90 then 1 else 0 end) / count(sid) as rate_90 from sc
group by cid order by num desc, cid) as std_sc_situation, course
where std_sc_situation.cid = course.cid;

-- 15. 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
select cid, score, @currank := @currank + 1 as rankid from
(select @currank := 0) as t, sc order by score desc;

-- 15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次（比如1，2，3，3，3，4）
select sc.cid, score,
case when @frontscore = score then @currank
    when @frontscore := score then @currank := @currank + 1 end as rankid
from (select @currank := 0, @frontscore := null) as t, sc order by score desc;

select 
    score, 
    convert(@i := @i + (@pre <> ( @pre := score)), signed) rankid,
    (@ii := @ii + (@preii <> ( @preii := score))) as rankidddd
from 
    sc, 
    (select @i := 0, @ii := 0, @pre := -1, @preii := -1) init 
order by score desc;

-- 16.  查询学生的总成绩，并进行排名，总分重复时保留名次空缺(比如1，2，3，4，5，6）
select t1.*, @currank := @currank+1 as rankid from (
select sc.SId, sum(score) from sc GROUP BY sc.SId ORDER BY sum(score) desc) as t1,
(select @currank:=0) as t;

-- 16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
select t1.*,
case when @lasttotalscore = t1.totalscore then @currank
    when @lasttotalscore := t1.totalscore then @currank := @currank + 1 end as rankid
from (select @lasttotalscore := null, @currank := 0) as t2,
(select sid, sum(score) as totalscore from sc group by sid order by totalscore desc) as t1;

-- 17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
select course.cname, std_sc.* from course,
(select cid, count(sid) as student_num,
sum(case when score < 60 then 1 else 0 end) as num_60,
concat(sum(case when score < 60 then 1 else 0 end) / count(sid) * 100, "%") as rate_num_60,
sum(case when score < 70 and score >= 60 then 1 else 0 end) as num_70,
concat(sum(case when score < 70 and score >= 60 then 1 else 0 end) / count(sid) * 100, "%") as rate_num_70,
sum(case when score < 85 and score >= 70 then 1 else 0 end) as num_85,
concat(sum(case when score < 85 and score >= 70 then 1 else 0 end) / count(sid) * 100, "%") as rate_num_85,
sum(case when score <= 100 and score >= 85 then 1 else 0 end) as num_100,
concat(sum(case when score <= 100 and score >= 85 then 1 else 0 end) / count(sid) * 100, "%") as rate_num_100
from sc group by cid) as std_sc where course.cid = std_sc.cid;

-- 18. 查询各科成绩前三名的记录
-- 思路：大于前三名的成绩数量一定小于3
select * from sc where (select count(sid) from sc as t where sc.cid = t.cid and t.score > sc.score) < 3 order by cid, score desc;

-- 19. 查询每门课程被选修的学生数(每门课的选课人数)
select cid, count(sid) as num from sc group by cid order by num desc;

-- 20. 查询出只选修两门课程的学生学号和姓名
select student.sname, student.sid from student, (select sid, count(cid) as num from sc group by sid having num = 2) as t
where student.sid = t.sid;

-- 21. 查询男生、女生人数
select count(sid) as num from student group by ssex;

-- 22. 查询名字中含有「风」字的学生信息
select * from student where sname regexp "风";
select * from student where sname like "%风%";

-- 23. 查询同名同性学生名单，并统计同名人数
select a.* from student as a, student as b where a.sname = b.sname and a.ssex = b.ssex and a.sid != b.sid;
select student.* from student right join (select sname, ssex, count(sid) as 同名人数 from student group by sname, ssex having 同名人数 > 1) as t
on student.sname = t.sname and student.ssex = t.ssex;

-- 24. 查询 1990 年出生的学生名单
select student.* from student where student.sage regexp "^1990";

-- 25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
select cid, avg(score) as avg_score from sc group by cid order by avg_score desc, cid;

-- 26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩 
select t.sid, sname, t.avg_score from student, (select sid, avg(score) avg_score from sc group by sid having avg_score >= 85) as t
where t.sid = student.sid;

-- 27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数 
select student.sname, sc.score, sc.score from sc, course, student
where sc.cid = course.cid and course.cname = "数学" and 
sc.score < 60  and student.sid = sc.sid;

-- 28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
select student.*, sc.cid, case when sc.score is null then 0 else sc.score end as score from student left join sc on student.sid = sc.sid
order by student.sid, sc.score desc; -- 这里我额外使用了case语句，其实就要求而言是画蛇添足的

-- 29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
select student.*, course.cname, sc.score from student, sc, course where student.sid = sc.sid and course.cid = sc.cid
and sc.score > 70;

-- 30. 查询不及格的课程
select distinct cid from sc where score < 60;

-- 31. 查询课程编号为 02 且课程成绩在 80 分以上的学生的学号和姓名
-- 内联结也可
select * from student where sid in (select distinct sid from sc where cid = "02" and score > 80);

-- 32. 求每门课程的学生人数 
select cid, count(sid) as num from sc group by cid;

-- 33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
select student.*, teacher.tname, course.cname, sc.score from student, sc, course, teacher
where student.sid = sc.sid and sc.cid = course.cid and course.tid = teacher.tid and teacher.tname = "张三" 
order by sc.score desc limit 1; 

-- 34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
select student.*, sc1.score from sc as sc1, student
where student.sid = sc1.sid and (select count(sid) from sc as sc2 where sc1.cid = sc2.cid and sc2.score > sc1.score) < 1
and sc1.cid = (select distinct sc.cid from sc, course, teacher where sc.cid = course.cid and course.tid = teacher.tid and teacher.tname = "张三");

-- 下面这种方法是预先计算出排名，然后再取排名id为1的值，和上面的其实本质是一样的
select student.*,t1.score
from student INNER JOIN (select sc.SId,sc.score,
case when @fontage=sc.score then @rankid when @fontage:=sc.score then @rankid := @rankid + 1 end  as rankid
from course ,teacher ,sc,(select @fontage:=null,@rankid:=0) as t
where course.CId=sc.CId
and course.TId=teacher.TId
and teacher.Tname='张三'
ORDER BY sc.score DESC) as t1 on student.SId=t1.SId
where t1.rankid=1;

-- 35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select  student.sname, result.sid, sc.cid, sc.score from student, sc,
(select distinct sc1.sid from sc as sc1, sc as sc2 where sc1.sid = sc2.sid and sc1.cid != sc2.cid and sc1.score = sc2.score) as result
where student.sid = sc.sid and sc.sid =  result.sid;

-- 36. 查询每门功课成绩最好的前两名
select * from sc as sc1 where (select count(sid) from sc as sc2 where sc2.cid = sc1.cid and sc2.score > sc1.score) < 2 order by sc1.cid, sc1.score desc;

-- 37. 统计每门课程的学生选修人数（超过 5 人的课程才统计）。
select cid, count(sid) as num from sc group by cid having num > 5;

-- 38. 检索至少选修两门课程的学生学号 
select sid, count(cid) as num from sc group by sid having num > 1;

select distinct t1.sid from sc as t1 where (select count(* )from sc where t1.sid=sc.sid)>=2;

-- 39. 查询选修了全部课程的学生信息
select student.* from student, (select sid from sc group by sid having count(cid) = (select count(cid) from course))
as result where student.sid = result.sid;

-- 40. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
select sname, sid, timestampdiff(year, sage, curdate()) as age from student;


-- student; sid, sname, sage(datetime), ssex
-- 			sc: sid, cid, score
-- 	course: cid, cname, tid
-- teacher: tid tname



