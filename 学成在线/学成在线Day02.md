# 学成在线Day02

### 1 开发持久层

在真实开发中，切记从底层向上层开发。例如项目应该先写持久层(mapper)再写业务层(service)

#### 1.1 分页查询代码

```
@Test
public void testCourseBaseMapper(){
    CourseBase courseBase = courseBaseMapper.selectById(18);
    System.out.println(courseBase);

    //拼装分页查询条件
    QueryCourseParamsDto queryCourseParamsDto = new QueryCourseParamsDto();
    queryCourseParamsDto.setCourseName("java");//课程名称为查询条件

    //封装查询条件
    LambdaQueryWrapper<CourseBase> courseBaseLambdaQueryWrapper = new LambdaQueryWrapper<>();
    //根据课程名称模糊查询,sql为course_base.name like '%?%'
    courseBaseLambdaQueryWrapper.like(StringUtils.isNotEmpty(queryCourseParamsDto.getCourseName()),
            CourseBase::getName,
            queryCourseParamsDto.getCourseName());
    //根据课程状态查询,sql为course_base.audit_status = ?
    courseBaseLambdaQueryWrapper.like(StringUtils.isNotEmpty(queryCourseParamsDto.getAuditStatus()),
            CourseBase::getAuditStatus,
            queryCourseParamsDto.getAuditStatus());

    //创建分页查询类
    PageParams pageParams = new PageParams(1L,2L);
    //创建分页对象,参数为当前页码,每页记录数
    Page<CourseBase> page = new Page<>(pageParams.getPageNo(), pageParams.getPageSize());
    //获取分页查询结果
    Page<CourseBase> courseBasePage = courseBaseMapper.selectPage(page, courseBaseLambdaQueryWrapper);
    //获取数据列表
    List<CourseBase> records = courseBasePage.getRecords();
    //获取记录总数
    Long total = courseBasePage.getTotal();

    PageResult<CourseBase> result = new PageResult<>(records,total,pageParams.getPageNo(), pageParams.getPageSize());

    System.out.println(result);
}
```

本篇用到大量mybatis-plus内容,先去学习这块内容