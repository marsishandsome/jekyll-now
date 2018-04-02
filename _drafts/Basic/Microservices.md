# Microservices

### Links
- [Microservice architecture patterns and best practices](http://microservices.io/)
- [Introduction to Microservices](http://www.oschina.net/translate/introduction-to-microservices) --Chris Richardson
- [Microservice Trade-Offs](http://martinfowler.com/articles/microservice-trade-offs.html) --Martin Fowler

### Nginx
- [WIKI](http://en.wikipedia.org/wiki/Nginx)

### Netflix
- [WIKI](http://en.wikipedia.org/wiki/Netflix)
- [Netflix Open Source Software Center](http://netflix.github.io/#repo)
- [The Netflix Tech Blog](http://techblog.netflix.com/)


### 参考文章

##### [Adopting Microservices at Netflix: Lessons for Architectural Design](http://nginx.com/blog/microservices-at-netflix-architectural-best-practices/)
- 微服务架构是一个：service-oriented architecture composed of loosely coupled elements that have bounded contexts
- 为每个微服务建立不同的数据后端，这些数据后端不互相依赖
- 如果需要重写某个服务，可以保留就的服务，添加新的服务，等到新的服务运行稳定以后，替换旧的服务
- 每个微服务有各自的Build工程
- 部署到容器
- 让微服务做到无状态，这样可以做到auto scaling

##### [Fast Delivery nginx.conf2014, October 2014](https://youtu.be/5qJ_BibbMLw)

##### [Adopting Microservices at Netflix: Lessons for Team and Process Design](http://nginx.com/blog/adopting-microservices-at-netflix-lessons-for-team-and-process-design/)


##### [THE HIDDEN COSTS OF MICROSERVICES](http://www.stackbuilders.com/news/the-hidden-costs-of-microservices)

##### [Microservices at Netflix](http://www.slideshare.net/stonse/microservices-at-netflix)

##### [A Microscope on Microservices](http://techblog.netflix.com/2015/02/a-microscope-on-microservices.html)
