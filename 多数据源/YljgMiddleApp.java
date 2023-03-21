package com.wondersgroup.yss.yljg.middle;

import com.wondersgroup.whs.framework.components.id.client.IdClient;
import com.wondersgroup.whs.framework.dao.id.IdGenerator;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.cache.CacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * @Description:
 * @Author: CL
 * @Date: 2021/8/5 15:19
 * @Version: 1.0
 */
//这个注解去除掉默认的数据库配置，然后我们自己去配置database.
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@RestController
@Slf4j
public class YljgMiddleApp {
    private static LocalDateTime startTime;

    public static void main(String[] args) {
        SpringApplication.run(YljgMiddleApp.class,args);
        startTime = LocalDateTime.now();
    }

    @Bean
    public RedisTemplate lockerRedisTemplate(RedisTemplate redisTemplate) {
        return redisTemplate;
    }

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration configuration = RedisCacheConfiguration.defaultCacheConfig().serializeValuesWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()))
                .entryTtl(Duration.ofSeconds(120));
        RedisCacheManager redisCacheManager = RedisCacheManager.RedisCacheManagerBuilder
                .fromConnectionFactory(connectionFactory).cacheDefaults(configuration).build();

        return redisCacheManager;
    }

    @Bean
    public IdClient idClient(@Value("${id.dataCenterId:4}") int dataCenterId,
                             @Value("${id.machineId:0}") int machineId) {
        return IdClient.create(dataCenterId, machineId);
    }

    @Bean
    public IdGenerator idGenerator(IdClient idClient) {
        return new IdGenerator(idClient);
    }

    @Bean
    public CommandLineRunner runner(){
        return (args)->{
            log.info("服务在{}启动成功", DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()));
        };
    }

    @GetMapping(value="/readiness")
    public String readinessProbe(){
        String message = String.format("服务在%s启动成功",DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(startTime));
        return message;
    }
}
