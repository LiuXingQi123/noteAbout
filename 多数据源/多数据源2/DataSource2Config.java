package com.wondersgroup.yss.yljg.middle.config;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;

@Configuration
//1.指定扫描mapper接口包，2.指的使用sqlSessionFactory是哪个
@MapperScan(basePackages = "com.wondersgroup.yss.yljg.middle.dao2.**", sqlSessionTemplateRef = "mysql2SqlSessionTemplate")
public class DataSource2Config {

    //创建dataSource
    @Bean(name = "mysql2DataSource")
    @ConfigurationProperties(prefix = "spring.datasource.mysql2")
    public DataSource dataSource2() {
        //会自动拿到spring.datasource中的配置，创建一个DruidDataSource
        return DataSourceBuilder.create().build();
    }

    //创建sqlsessionfactory
    @Bean(name = "mysql2SqlSessionFactory")
    public SqlSessionFactory sqlSessionFactory2(@Qualifier("mysql2DataSource") DataSource dataSource) throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        //指定数据源
        bean.setDataSource(dataSource);
        //指定数据源对应的mapper.xml文件
        bean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources("classpath:com/wondersgroup/yss/yljg/middle/dao2/**/*.xml"));
        return bean.getObject();
    }

    //创建事务管理器
    @Bean(name = "mysql2TransactionManager")
    public DataSourceTransactionManager transactionManager2(@Qualifier("mysql2DataSource") DataSource dataSource) {
        //指定数据源
        return new DataSourceTransactionManager(dataSource);
    }

    //创建sqlsession模板
    @Bean(name = "mysql2SqlSessionTemplate")
    public SqlSessionTemplate sqlSessionTemplate2(@Qualifier("mysql2SqlSessionFactory") SqlSessionFactory sqlSessionFactory) throws Exception {
        return new SqlSessionTemplate(sqlSessionFactory);
    }

}
