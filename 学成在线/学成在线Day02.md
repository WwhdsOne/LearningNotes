# 学成在线Day02



# 开发持久层

在真实开发中，切记从底层向上层开发。例如项目应该先写持久层(mapper)再写业务层(service)

# 分页查询测试代码

```java
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

本篇用到大量mybatis-plus内容,先去学习这块内容(2.11已学习完Mybatis-plus)

### 利用Http Client插件生成http请求

插件:

![image-20240211163239135](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240211163239135.png)

点击此处可以生成Http请求

![image-20240211163338945](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240211163338945.png)



例如分页查询的请求可以这么写

```http
### 查询课程信息
POST http://localhost:8080/course/list?pageNo=1&pageSize=2
Content-Type: application/json

{
  "auditStatus": "202004",
  "courseName": "java",
  "publishStatus": ""
}
```

在项目根目录下建立文件夹统一存放请求测试

![image-20240211163614502](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240211163614502.png)

为了方便将来和网关集成测试，这里我们把测试主机地址在配置文件http-client.env.json 中配置![image-20240211163817932](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240211163817932.png)

注意要调用http-client.env.json文件内容需要将使用以下环境运行调整至dev![image-20240211164035140](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240211164035140.png)

# 跨域三种解决方案

在浏览器通过http://localhost:8601/地址访问前端工程。

chrome浏览器报错如下：

> Access to XMLHttpRequest at  'http://localhost:63110/system/dictionary/all' from origin  'http://localhost:8601' has been blocked by CORS policy: No  'Access-Control-Allow-Origin' header is present on the requested resource.  

Firefox浏览器报错如下：

> 已拦截跨源请求：同源策略禁止读取位于 http://localhost:63110/system/dictionary/all 的远程资源。（原因：CORS  头缺少 'Access-Control-Allow-Origin'）。状态码：200。  

提示：从http://localhost:8601访问http://localhost:63110/system/dictionary/all被CORS policy阻止，因为没有Access-Control-Allow-Origin 头信息。CORS全称是 cross origin resource share 表示跨域资源共享。

出这个提示的原因是基于浏览器的同源策略，去判断是否跨域请求，同源策略是浏览器的一种安全机制，从一个地址请求另一个地址，如果协议、主机、端口三者全部一致则不属于跨域，否则有一个不一致就是跨域请求。

比如：

- 从http://localhost:8601 到  http://localhost:8602 由于端口不同，是跨域。

- 从http://192.168.101.10:8601 到  http://192.168.101.11:8601 由于主机不同，是跨域。

- 从http://192.168.101.10:8601 到  [https://192.168.101.10:8601](https://192.168.101.11:8601) 由于协议不同，是跨域。

注意：服务器之间不存在跨域请求。

浏览器判断是跨域请求会在请求头上添加origin，表示这个请求来源哪里。

比如：

> GET / HTTP/1.1   
>
> Origin: http://localhost:8601  

服务器收到请求判断这个Origin是否允许跨域，如果允许则在响应头中说明允许该来源的跨域请求，如下：

> Access-Control-Allow-Origin：http://localhost:8601  

如果允许任何域名来源的跨域请求，则响应如下：

> Access-Control-Allow-Origin：*  

### 第一种 JSON

通过script标签的src属性进行跨域请求，如果服务端要响应内容则首先读取请求参数callback的值，callback是一个回调函数的名称，服务端读取callback的值后将响应内容通过调用callback函数的方式告诉请求方。如下图：

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318123843870.png" alt="image-20240318123843870" style="zoom:50%;" />


### 第二种 添加响应头

服务端在响应头添加 `Access-Control-Allow-Origin：*`

### 第三种 通过nginx代理跨域

由于服务端之间没有跨域，浏览器通过nginx去访问跨域地址。

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318124740478.png" alt="image-20240318124740478" style="zoom:50%;" />

1. 浏览器先访问http://192.168.101.10:8601 nginx提供的地址，进入页面

2. 此页面要跨域访问http://192.168.101.11:8601 ，不能直接跨域访问http://www.baidu.com:8601 ，而是访问nginx的一个同源地址，比如：http://192.168.101.11:8601/api ，通过http://192.168.101.11:8601/api 的代理去访问http://www.baidu.com:8601。

这样就实现了跨域访问。

浏览器到http://192.168.101.11:8601/api 没有跨域

nginx到http://www.baidu.com:8601通过服务端通信，没有跨域。

***本项目采用第二种方法解决跨域问题***

# 前后端联调

这里进行前后联调的目的是体会前后端联调的流程，测试的功能为课程查询功能。

1、启动前端工程，再启内容管理服务端。

2、修改服务端地址

前端默认连接的是项目的网关地址，由于现在网关工程还没有创建，这里需要更改前端工程的参数配置文件 ，修改网关地址为内容管理服务的地址。 

启动前端工程，用前端访问后端接口，观察前端界面的数据是否正确。

# 课程分类查询

分类表中的数据为树形结构：

![image-20240211185359606](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240211185359606.png)

### 树形数据库查询

#### 树层级确定

课程分类表是一个树型结构，其中parentid字段为父结点ID，它是树型结构的标志字段。

如果树的层级固定可以使用表的自链接去查询，比如：我们只查询两级课程分类，可以用下边的SQL

```mysql
select *
from course_category one
         inner join course_category two on one.id = two.parentid
where one.parentid = 1
  and one.is_show = 1
  and two.is_show = 1
order by one.orderby, two.orderby;
```

注意此时的order by 根据两个条件，其效果是先根据one.orderby排序,其内部排序结果再由two.orderby排序。

#### 树层级不确定

此时可以使用MySQL递归实现，使用with语法，如下：

```mysql
WITH RECURSIVE cte_name (column_list) AS (
    SELECT initial_query_result
    UNION [ALL]
    SELECT recursive_query
    FROM cte_name
    WHERE condition
)
SELECT * FROM cte_name;
```

MySQL with Recursive语法详解

1. WITH RECURSIVE：表示要使用递归查询的方式处理数据。

2. cte_name：给这个临时的递归表取个名字，可以在初始查询和递归查询中引用。
3. column_list：表示cte_name查询表中包含的列名，列名之间用逗号分隔。
4. initial_query_result：表示初始的查询结果，应该与column_list中的列名对应。
5. UNION：表示将两个查询结果集进行联合，使用UNION ALL则表示保留重复数据。
6. recursive_query：表示递归查询语句，应当与column_list中的列名对应。
7. condition：表示递归查询的终止条件，需要使用cte_name中的列进行判
8. SELECT * FROM cte_name：表示最终返回的查询结果集，可以通过cte_name查询表中的列名进行指定。

下边是一个递归的简单例子：

```mysql
with RECURSIVE t1 AS   (    
	SELECT 1 as n    
	UNION ALL    
	SELECT n + 1 FROM t1 WHERE n < 5   
)   
SELECT * FROM t1;
```

输出：

![image-20240211193838531](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240211193838531.png)

课程分类表层级固定查询sql:

```mysql
select *
from course_category one
         inner join course_category two on one.id = two.parentid
where one.parentid = 1
  and one.is_show = 1
  and two.is_show = 1
order by one.orderby, two.orderby;
```

课程分类表层级不固定查询sql:

```mysql
with recursive t1 as (
    select * from course_category where id = '1'
    union all
    select t2.* from course_category t2 inner join t1 on t2.parentid = t1.id
)
select * from t1 order by t1.id;
```

以上是我们研究了树型表的查询方法，通过递归的方式查询课程分类比较灵活，因为它可以不限制层级。

mysql为了避免无限递归默认递归次数为1000，可以通过设置cte_max_recursion_depth参数增加递归深度，还可以通过max_execution_time限制执行时间，超过此时间也会终止递归操作。

mysql递归相当于在存储过程中执行若干次sql语句，java程序仅与数据库建立一次链接执行递归操作，所以只要控制好递归深度，控制好数据量性能就没有问题。

思考：如果java程序在递归操作中连接数据库去查询数据组装数据，这个性能高吗？

答：若在mysql中执行递归查询，java与数据库只用连接一次。若在java中使用递归查询则会连接多次，浪费性能。

### service层处理

```java
@Override
public List<CourseCategoryDTO> queryTreeNodes(String id) {
    //调用mapper查询分类信息
    List<CourseCategoryDTO> courseCategoryDTOS = courseCategoryMapper.selectTreeNodes(id);
    //封装成list类型返回
    //将list转换成map,key为id,value为CourseCategoryDTO
    Map<String, CourseCategoryDTO> map = courseCategoryDTOS.stream()
        .collect(Collectors.toMap(CourseCategory::getId, value -> value, (key1, key2) -> key2));
    //遍历list,查找collect子节点
    List<CourseCategoryDTO> result = new ArrayList<>();
    courseCategoryDTOS.stream().filter(item -> !id.equals(item.getId())) //去除根节点
        .forEach(item -> {
            if ( item.getParentid().equals(id) ) {
                result.add(item);
            }
            CourseCategoryDTO courseCategoryDTO = map.get(item.getParentid());
            //父节点属于要要找的节点则此时会在map中,若不是要找的节点则会被filter过滤
            if ( courseCategoryDTO != null ) {
                //如果该父节点的子节点集合为空,设置一个新的集合
                if ( courseCategoryDTO.getChildrenTreeNodes() == null ) {
                    courseCategoryDTO.setChildrenTreeNodes(new ArrayList<>());
                }
                courseCategoryDTO.getChildrenTreeNodes().add(item);
            }
        });
    return result;
}
```

# 新增课程

注意涉及到增删改查记得要添加**@Transactional**注解

注意当事务回滚时ID仍然自增，因为innodb的auto_increament的计数器记录的当前值是保存在存内 存中的，并不是存在于磁盘上，当mysql server处于运行的时候，这个计数值只会随着 insert 改增长，不会随着delete而减少。

所以最后要在courseMarket设置ID，而不是直接插入

```java
@Transactional
@Override
public CourseBaseInfoDTO createCourseBaseInfo(Long companyId, AddCourseDTO addcourseDTO) {
    //合法性校验
    if (StringUtils.isBlank(addcourseDTO.getName())) {
        throw new RuntimeException("课程名称为空");
    }

    if (StringUtils.isBlank(addcourseDTO.getMt())) {
        throw new RuntimeException("课程分类为空");
    }

    if (StringUtils.isBlank(addcourseDTO.getSt())) {
        throw new RuntimeException("课程分类为空");
    }

    if (StringUtils.isBlank(addcourseDTO.getGrade())) {
        throw new RuntimeException("课程等级为空");
    }

    if (StringUtils.isBlank(addcourseDTO.getTeachmode())) {
        throw new RuntimeException("教育模式为空");
    }

    if (StringUtils.isBlank(addcourseDTO.getUsers())) {
        throw new RuntimeException("适应人群为空");
    }

    if (StringUtils.isBlank(addcourseDTO.getCharge())) {
        throw new RuntimeException("收费规则为空");
    }

    //1.向课程信息表(course_Base)写入信息
    CourseBase courseBase = new CourseBase();
    BeanUtils.copyProperties(addcourseDTO,courseBase);
    courseBase.setCompanyId(companyId);
    courseBase.setCreateDate(LocalDateTime.now());
    //审核状态默认未提交
    courseBase.setAuditStatus("202002");
    //发布状态为未发布
    courseBase.setStatus("203001");
    int insert = courseBaseMapper.insert(courseBase);
    if(insert <= 0){
        throw new RuntimeException("添加课程失败");
    }
    //2.向课程营销表(course_market)写入信息
    //课程营销信息
    CourseMarket courseMarket = new CourseMarket();
    Long courseId = courseBase.getId();
    BeanUtils.copyProperties(addcourseDTO,courseMarket);
    courseMarket.setId(courseId);
    int i = saveCourseMarket(courseMarket);
    if(i<=0){
        throw new RuntimeException("保存课程营销信息失败");
    }
    //查询课程基本信息及营销信息并返回
    return getCourseBaseInfo(courseId);
}
```

# 异常处理

异常处理方法用的三个注解:

```java
@ResponseBody									  //将java对象转换成json格式
@ExceptionHandler(XueChengPlusException.class)    //利用字节码文件捕获对应异常
@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR) //设置响应码
```

注意到类上用了

```java
@ControllerAdvice
```

我们可以使用

```java
@RestControllerAdvice
```

@RestControllerAdvice注解包含了@ControllerAdvice注解和@ResponseBody注解



