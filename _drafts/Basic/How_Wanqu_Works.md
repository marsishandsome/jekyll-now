# How Wanqu Works?
- [湾区日报是如何运作的？](http://weibo.com/p/1001593846350310617958)
- [Deploying branches to GitHub.com](http://githubengineering.com/deploying-branches-to-github-com/)

### Slack
- 在Slack上跟机器人wanqu-ops说话，发给它一个链接。然后它就自动提取标题、提取图片、构建slug、关联某一期（issue），最后创建新文章
- [官网](https://slack.com/)

### Hubot
- 这个机器人除了分担发文章的部分工作外，还承担了重大的运维职责，比如部署新代码、tail log、查看关键指标（新增微博粉丝数、网站访问量等）、重启服务器等
- [官网](https://hubot.github.com/)
- [Github](https://github.com/github/hubot)
- [Getting Started With Hubot](https://hubot.github.com/docs/)

```
git clone https://github.com/github/hubot.git
yum install -y nodejs npm --enablerepo=epel
npm install -g yo generator-hubot --allow-root
yo hubot \
--owner="Mars <mars@example.com>" \
--name="Mars" \
--description="Mars Test Robot" \
--adapter=campfire \
--defaults
```
### Django
- 网站是Python/Django写的，数据库用的是Postgres
- [官网](https://www.djangoproject.com/)

### MailChimp
- MailChimp每天太平洋时间晚上9点会读取 wanqu.co/feed，然后群发邮件
- [官网](http://mailchimp.com/)

### IFTTT
- Facebook页面的更新理论上也能用API，但我懒。所以就用IFTTT同步Twitter账号上的内容。
- [官网](https://ifttt.com/)

### Celerybeat
- 每小时有一定概率自动发微博与Twitter，每个社交账号的API调用都是一个Celery task。
- [官网](http://celery.readthedocs.org/en/latest/) --Distributed Task Queue

### RabbitMQ
- Message broker用的是RabbitMQ
- [官网](https://www.rabbitmq.com/)

### Try
- [Steps to Install Hubot in Slack using Heroku](https://gist.github.com/trey/9690729)
