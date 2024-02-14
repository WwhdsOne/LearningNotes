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

可以使用SQl语句一次完成，待补充