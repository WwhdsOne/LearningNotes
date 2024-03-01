# 学成在线Day10



# JWT

## 普通令牌的问题

客户端申请到令牌，接下来客户端携带令牌去访问资源，

到资源服务器将会校验令牌的合法性。

资源服务器如何校验令牌的合法性？

我们以OAuth2的密码模式为例进行说明：

![image-20240301171801030](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301171801030.png)

从第4步开始说明：

1、客户端携带令牌访问资源服务获取资源。

2、资源服务远程请求认证服务校验令牌的合法性

3、如果令牌合法资源服务向客户端返回资源。

这里存在一个问题：

就是校验令牌需要远程请求认证服务，客户端的每次访问都会远程校验，执行性能低。

如果能够让资源服务自己校验令牌的合法性将省去远程请求认证服务的成本，提高了性能。如下图：

![image-20240301171855970](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301171855970.png)

如何解决上边的问题，实现资源服务自行校验令牌。

令牌采用JWT格式即可解决上边的问题，用户认证通过后会得到一个JWT令牌，JWT令牌中已经包括了用户相关的信息，客户端只需要携带JWT访问资源服务，资源服务根据事先约定的算法自行完成令牌校验，无需每次都请求认证服务完成授权。

## 什么是JWT

JSON Web Token（JWT）是一种使用JSON格式传递数据的网络令牌技术，它是一个开放的行业标准（RFC 7519），它定义了一种简洁的、自包含的协议格式，用于在通信双方传递json对象，传递的信息经过数字签名可以被验证和信任，它可以使用HMAC算法或使用RSA的公钥/私钥对来签名，防止内容篡改。官网：https://jwt.io/

使用JWT可以实现无状态认证。

```java
package com.xuecheng.auth.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.provider.token.AuthorizationServerTokenServices;
import org.springframework.security.oauth2.provider.token.DefaultTokenServices;
import org.springframework.security.oauth2.provider.token.TokenEnhancerChain;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.InMemoryTokenStore;
import org.springframework.security.oauth2.provider.token.store.JwtAccessTokenConverter;
import org.springframework.security.oauth2.provider.token.store.JwtTokenStore;

import java.util.Arrays;

/**
 * @author Administrator
 * @version 1.0
 **/
@Configuration
public class TokenConfig {

    private String SIGNING_KEY = "mq123";

    @Autowired
    TokenStore tokenStore;

//    @Bean
//    public TokenStore tokenStore() {
//        //使用内存存储令牌（普通令牌）
//        return new InMemoryTokenStore();
//    }

    @Autowired
    private JwtAccessTokenConverter accessTokenConverter;

    @Bean
    public TokenStore tokenStore() {
        return new JwtTokenStore(accessTokenConverter());
    }

    @Bean
    public JwtAccessTokenConverter accessTokenConverter() {
        JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
        converter.setSigningKey(SIGNING_KEY);
        return converter;
    }

    //令牌管理服务
    @Bean(name="authorizationServerTokenServicesCustom")
    public AuthorizationServerTokenServices tokenService() {
        DefaultTokenServices service=new DefaultTokenServices();
        service.setSupportRefreshToken(true);//支持刷新令牌
        service.setTokenStore(tokenStore);//令牌存储策略

        TokenEnhancerChain tokenEnhancerChain = new TokenEnhancerChain();
        tokenEnhancerChain.setTokenEnhancers(Arrays.asList(accessTokenConverter));
        service.setTokenEnhancer(tokenEnhancerChain);

        service.setAccessTokenValiditySeconds(7200); // 令牌默认有效期2小时
        service.setRefreshTokenValiditySeconds(259200); // 刷新令牌默认有效期3天
        return service;
    }
}

```

申请令牌http测试：

```http
POST {{auth_host}}/oauth/token?client_id=XcWebApp&client_secret=XcWebApp&grant_type=password&username=zhangsan&password=123
```

## 测试资源服务校验令牌

拿到了jwt令牌下一步就要携带令牌去访问资源服务中的资源，本项目各个微服务就是资源服务

在内容管理服务的content-api工程中添加依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
</dependency>
```

http请求携带jwt令牌访问课程信息

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsi...
```

注意`Authorization: Bearer`是规定用来校验的字段，jwt令牌过长结尾省略

## 测试获取用户身份

```java
@ApiOperation("根据课程id查询课程基础信息")
@GetMapping("/course/{courseId}")
public CourseBaseInfoDto getCourseBaseById(@PathVariable("courseId") Long courseId){
    //取出当前用户身份
    //SecurityContextHolder底层就是ThreadLocal
    Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    System.out.println(principal);
    return courseBaseInfoService.getCourseBaseInfo(courseId);
}
```

# 网关认证

## 技术方案

到目前为止，测试通过了认证服务颁发jwt令牌，客户端携带jwt访问资源服务，资源服务对jwt的合法性进行验证。如下图：

![image-20240301180738561](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301180738561.png)

仔细观察此图，遗漏了本项目架构中非常重要的组件：网关，加上网关并完善后如下图所示：

![image-20240301180755266](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301180755266.png)

所有访问微服务的请求都要经过网关，在网关进行用户身份的认证可以将很多非法的请求拦截到微服务以外，这叫做网关认证。

下边需要明确网关的职责：

1、网站白名单维护

针对不用认证的URL全部放行。

2、校验jwt的合法性。

除了白名单剩下的就是需要认证的请求，网关需要验证jwt的合法性，jwt合法则说明用户身份合法，否则说明身份不合法则拒绝继续访问。

网关负责授权吗？

网关不负责授权，对请求的授权操作在各个微服务进行，因为微服务最清楚用户有哪些权限访问哪些接口。

## 实现网关认证

实现以下职责：

1、网站白名单维护

针对不用认证的URL全部放行。

2、校验jwt的合法性。

除了白名单剩下的就是需要认证的请求，网关需要验证jwt的合法性，jwt合法则说明用户身份合法，否则说明身份不合法则拒绝继续访问。

网关工程依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
</dependency>
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
</dependency>
```

配置白名单文件security-whitelist.properties

```properties
/**=\u4E34\u65F6\u5168\u90E8\u653E\u884C
/auth/**=\u8BA4\u8BC1\u5730\u5740
/content/open/**=\u5185\u5BB9\u7BA1\u7406\u516C\u5F00\u8BBF\u95EE\u63A5\u53E3
/media/open/**=\u5A92\u8D44\u7BA1\u7406\u516C\u5F00\u8BBF\u95EE\u63A5\u53E3
```

导入了四个文件，其中最重要的的是GatewayAuthFilter

其内部过滤器比较重要

过滤器代码

```java
@Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String requestUrl = exchange.getRequest().getPath().value();
        AntPathMatcher pathMatcher = new AntPathMatcher();
        //白名单放行
        for (String url : whitelist) {
            if (pathMatcher.match(url, requestUrl)) {
                return chain.filter(exchange);
            }
        }

        //检查token是否存在
        String token = getToken(exchange);
        if (StringUtils.isBlank(token)) {
            return buildReturnMono("没有认证",exchange);
        }
        //判断是否是有效的token
        OAuth2AccessToken oAuth2AccessToken;
        try {
            oAuth2AccessToken = tokenStore.readAccessToken(token);

            boolean expired = oAuth2AccessToken.isExpired();
            if (expired) {
                return buildReturnMono("认证令牌已过期",exchange);
            }
            return chain.filter(exchange);
        } catch (InvalidTokenException e) {
            log.info("认证令牌无效: {}", token);
            return buildReturnMono("认证令牌无效",exchange);
        }

    }
```

网关的三个主要功能：

1. 提供路由功能
2. 提供白名单
3. 校验jwt`合法性`