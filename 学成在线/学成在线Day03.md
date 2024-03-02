# 学成在线Day03

# JSR303校验

### 统一校验实现

首先在Base工程添加spring-boot-starter-validation的依赖

```xml
<dependency>       
	<groupId>org.springframework.boot</groupId>      
    <artifactId>spring-boot-starter-validation</artifactId>   
</dependency>  
```

在javax.validation.constraints包下有很多这样的校验注解，直接使用注解定义校验规则即可。

之后我们在数据传输类的属性直接添加注解即可，例如：

```java
	@NotEmpty(message = "课程名称不能为空")
    @ApiModelProperty(value = "课程名称", required = true)
    private String name;

    @NotEmpty(message = "适用人群不能为空")
    @Size(message = "适用人群内容过少", min = 10)
    @ApiModelProperty(value = "适用人群", required = true)
    private String users;
```

### **分组校验**

有时候在同一个属性上设置一个校验规则不能满足要求，比如：订单编号由系统生成，在添加订单时要求订单编号为空，在更新 订单时要求订单编写不能为空。此时就用到了分组校验，同一个属性定义多个校验规则属于不同的分组，比如：添加订单定义@NULL规则属于insert分组，更新订单定义@NotEmpty规则属于update分组，insert和update是分组的名称，是可以修改的。

下边举例说明

我们用class类型来表示不同的分组，所以我们定义不同的接口类型（空接口）表示不同的分组，由于校验分组是公用的，所以定义在 base工程中。如下：

```java
public class ValidationGroups {
	public interface Inster{};
	public interface Update{};
	public interface Delete{};
}
```

在校验规则的时候分组

```java
@NotEmpty(groups = {ValidationGroups.Inster.class},message = "添加课程名称不能为空")
@NotEmpty(groups = {ValidationGroups.Update.class},message = "修改课程名称不能为空")
// @NotEmpty(message = "课程名称不能为空")
@ApiModelProperty(value = "课程名称", required = true)
private String name;
```

# 修改课程

第一步我们需要获取课程信息

我们可以让前端回显分页查询数据

或者利用后端Api查询

这里我们选择后端Api查询

# 课程计划查询

常规开发,查询类似课程分类查询

由于层级固定，采用自连接查询

由于返回时数据并非符合要求，所以在select标签内使用resultMap来映射

```xml
<resultMap id="treeNodeResultMap" type="">
</resultMap>
<select id="selectTreeNodes" resultMap="treeNodeResultMap" parameterType="java.lang.Long">
```

注意collection中嵌套了association标签，移出去防止爆红

查询语句用到了

```xml
<resultMap> <association> <collection>
```

详细内容可以查看[MyBatis之ResultMap的association和collection标签详解 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/572129887)学习

查询语句如下

```xml
<resultMap id="treeNodeResultMap" type="com.xuecheng.content.model.dto.TeachplanDTO">
        <!-- 一级数据映射 -->
        <id     column="one_id"        property="id" />
        <result column="one_pname"      property="pname" />
        <result column="one_parentid"     property="parentid" />
        <result column="one_grade"  property="grade" />
        <result column="one_mediaType"   property="mediaType" />
        <result column="one_stratTime"   property="startTime" />
        <result column="one_endTime"   property="endTime" />
        <result column="one_orderby"   property="orderby" />
        <result column="one_courseId"   property="courseId" />
        <result column="one_coursePubId"   property="coursePubId" />
        <!-- 一级中包含多个二级数据 -->
        <collection property="teachPlanTreeNodes" ofType="com.xuecheng.content.model.dto.TeachplanDTO">
            <!-- 二级数据映射 -->
            <id     column="two_id"        property="id" />
            <result column="two_pname"      property="pname" />
            <result column="two_parentid"     property="parentid" />
            <result column="two_grade"  property="grade" />
            <result column="two_mediaType"   property="mediaType" />
            <result column="two_stratTime"   property="startTime" />
            <result column="two_endTime"   property="endTime" />
            <result column="two_orderby"   property="orderby" />
            <result column="two_courseId"   property="courseId" />
            <result column="two_coursePubId"   property="coursePubId" />
            <association property="teachplanMedia" javaType="com.xuecheng.content.model.po.TeachplanMedia">
                <id column="teachplanMeidaId"   property="id" />
                <result column="mediaFilename"   property="mediaFilename" />
                <result column="mediaId"   property="mediaId" />
            </association>
        </collection>
    </resultMap>
```

# 新增修改课程计划

我们用一个SaveTeachPlanDTO类即可完成新增和修改相关操作，减少了操作量，提高了代码复用率

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SaveTeachPlanDTO {
    private Long id;
    private String pname;
    private Long parentid;
    private Integer grade;
    private String mediaType;
    private Long courseId;
    private Long coursePubId;
    private String isPreview;
}
```

当我们需要确定插入数据的orderBy时，我们可以通过统计同类课程的数量并将其+1即可

```java
private Integer getTeachPlanCount(Long courseId,Long parentId){
        LambdaQueryWrapper<Teachplan> lambdaQueryWrapper = new LambdaQueryWrapper<>();
        lambdaQueryWrapper.eq(Teachplan::getCourseId,courseId);
        lambdaQueryWrapper.eq(Teachplan::getParentid,parentId);
        //计算个数
        return teachplanMapper.selectCount(lambdaQueryWrapper);
}
```

注意当我们添加大章节时前端不显示，我们需要把sql语句中的

```mysql
from teachplan one
     inner join teachplan two on two.parentid = one.id
     left join teachplan_media m1 on m1.teachplan_id = two.id
```

改为

```mysql
from teachplan one
     left join teachplan two on two.parentid = one.id
     left join teachplan_media m1 on m1.teachplan_id = two.id
```

