# 学成在线Day04



# 删除课程计划

课程计划添加成功，如果课程还没有提交时可以删除课程计划。

![image-20240214185143784](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240214185143784.png)

- 删除第一级别的章时要求章下边没有小节方可删除。 
- 删除第二级别的小节的同时需要将其它关联的视频信息也删除。
- 删除课程计划需要传输课程计划的id。

涉及多表删除需要开启事务

可以从IDEA数据库直接复制行的sql语句

![image-20240214193321392](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240214193321392.png)

修改圈中部分即可



# 课程计划排序

![image-20240214200241048](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240214200241048.png)

- 上移表示将课程计划向上移动。 
- 下移表示将课程计划向下移动。 
- 向上移动表示和上边的课程计划交换位置，将两个课程计划的排序字段值交换。 
- 向下移动表示和下边的课程计划交换位置，将两个课程计划的排序字段值交换。

可以使用SQl语句一次完成

```mysql
<!--根据方向和ID修改顺序-->
    <update id="updateOrderByDirectionAndId">
        update teachplan T1,					# 先设置三个表用来更新和保存状态
            teachplan T2,
            <if test="direction != null and direction == 'movedown'.toString()">
                (SELECT id,orderby
                FROM teachplan T3
                WHERE T3.course_id = #{teachplan.courseId}						
                AND T3.orderby > #{teachplan.orderby}					# 找到第一个比当前顺序大的行，和他的orderby进行就交换
                AND T3.parentid = #{teachplan.parentid}
                ORDER BY T3.orderby
                limit 1) T4
            </if>
            <if test="direction != null and direction == 'moveup'.toString()">
                (SELECT id,orderby
                FROM teachplan T3
                WHERE T3.course_id = #{teachplan.courseId}
                AND T3.orderby &lt; #{teachplan.orderby}				# 找到第一个比当前顺序小的行，和他的orderby进行就交换
                AND T3.parentid = #{teachplan.parentid}
                ORDER BY T3.orderby desc								# 注意此时是逆序
                limit 1) T4
            </if>
        SET T2.orderby = T1.orderby,
            T1.orderby = T2.orderby
        where T1.parentid = T2.parentid
          AND T1.course_id = T2.course_id
          AND T1.parentid = #{teachplan.parentid}
          AND T1.course_id = #{teachplan.courseId}
          AND T1.orderby = #{teachplan.orderby}
          AND T2.orderby = T4.orderby
          AND T1.id != T4.id;											# 防止其再次更新自己，确保只更新目标的两行
    </update>
```

# 师资管理

## 课程教师查询

调用mybatis-plus接口即可

## 添加教师

由于需要插入后返回数据，我们将Controller的返回类设置为CourseTeacher

当插入完成后，id字段会自动为插入实体类赋值

可以直接返回

## 删除教师和修改教师

基础增删查改



# 课程删除

涉及到的表比较多，需要细心处理

