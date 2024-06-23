# 1. @SpringBootApplication

- @Target({ElementType.TYPE})：这个元注解表示该注解可以用在类、接口（包括注解类型）或枚举声明上。  
- @Retention(RetentionPolicy.RUNTIME)：这个元注解表示该注解在运行时仍然有效，可以通过反射机制获取到。  
- @Documented：这个元注解表示如果一个类型使用了被@Documented注解的注解进行注解，那么这个注解将会被包含在JavaDoc中。  
- @Inherited：这个元注解表示一个注解在子类中可以被继承。如果一个使用了@Inherited修饰的注解修饰一个父类，那么子类也会通过继承得到这个注解。  
- @SpringBootConfiguration：这是Spring Boot的注解，表示当前类是配置类，并且会自动被Spring Boot扫描到。  
- @EnableAutoConfiguration：这也是Spring Boot的注解，它的作用是启动自动配置，Spring Boot会根据你添加的依赖自动配置你的Spring应用。例如，如果你的classpath下有spring-boot-starter-web，那么Spring Boot会认为你正在开发一个web应用，并自动启动Tomcat和Spring MVC。

# 2. @RestController

- @Target({ElementType.TYPE})：这个元注解表示该注解可以用在类、接口（包括注解类型）或枚举声明上。  
- @Retention(RetentionPolicy.RUNTIME)：这个元注解表示该注解在运行时仍然有效，可以通过反射机制获取到。  
- @Documented：这个元注解表示如果一个类型使用了被@Documented注解的注解进行注解，那么这个注解将会被包含在JavaDoc中。  
- @Controller：这是Spring框架的注解，用于标记一个类为Spring MVC控制器。控制器负责处理用户请求。  
- @ResponseBody：这是Spring框架的注解，用于表示控制器的方法返回的对象应该直接写入HTTP响应体中，而不是被视图解析器解析为一个视图。