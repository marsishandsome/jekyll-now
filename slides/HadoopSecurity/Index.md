# Hadoop Kerberos的那些坑 <br />顾亮亮 <br />2015.11.03

---
# Agenda
- Kerberos Introduction
- Token Expired Problem when Hadoop meet Kerberos
- How Spark solve the Problem
- Hadoop Kerberos Programming API

---
# Kerberos (百度百科)
> Kerberos这一名词来源于希腊神话 三个头的狗——地狱之门守护者

![](images/kerberos.jpg)

---
# Kerberos (Wikipedia)
> Kerberos /ˈkərbərəs/ is a computer network authentication protocol which works on the basis of 'tickets' to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Kerberos.svg/440px-Kerberos.svg.png)

---
# Authentication(认证) VS Authorization(授权)
- Authentication
> is the act of confirming the truth of an attribute of a single piece of data claimed true by an entity.

- Authorization
> is the function of specifying access rights to
resources related to information security and computer security in general and to access control in particular.

**Authentication is about who somebody is.**

**Authorisation is about what they're allowed to do.**

---
# Step 1: Authentication Service - TGT Delivery
**TGT: Ticket Granting Ticket**
![](images/kerberos2.PNG)
From: [The MIT Kerberos Administrator’s How-to Guide](http://www.kerberos.org/software/adminkerberos.pdf)

---
# Step 2: Ticket Granting Service - TGS Delivery
**TGS: Ticket Granting Service**
![](images/kerberos3.PNG)

---
# Diagrams
![](images/kerberos1.PNG)

---
# Overal
![](images/kerberos4.PNG)

---
# Token Expired Problem when Hadoop meet Kerberos

---
# Hadoop Authentication Flow
![](images/hadoop.PNG)
From: [Hadoop Security Design](http://www.valleytalk.org/wp-content/uploads/2013/03/hadoop-security-design.pdf)

---
# HDFS Authentication (Case 1: Sigle JVM Application)
![](images/hadoop2.PNG)

1. 用Keytab从KDC拿到TGT，进而拿到对应NameNode的TGS
2. 用TGS向NameNode做验证，进而拿到BlocksToken
3. 用BlocksToken从DataNode读取数据

### Block Token
- TokenID = {expirationDate, keyID, ownerID, blockID, accessModes}
- TokenAuthenticator = HMAC-SHA1(key, TokenID)
- Block Access Token = {TokenID, TokenAuthenticator}

---
# HDFS Authentication (Case 2: Yarn Application)
### <font color="red">Yarn上运行的Executor如何做验证？</font>

1. client用Keytab从KDC拿到TGT，进而拿到对应NameNode的TGS
2. client用TGS向NameNode做验证，然后获取HDFS Delegation Token
3. client把HDFS Delegation Token发送到各个Executor
3. Executor用HDFS Delegation Token向NameNode获取BlocksToken
4. Executor用BlocksToken从DataNode读取数据

### HDFS Delegation Token
- TokenID = {ownerID, renewerID, issueDate, maxDate, sequenceNumber}
- TokenAuthenticator = HMAC-SHA1(masterKey, TokenID)
- Delegation Token = {TokenID, TokenAuthenticator}

---
# Token Expired Problem when Hadoop meet Kerberos

1. keytab (long term)
2. TGT (max life time = 3 days)
3. TGS for NameNode (max life time = 3 days)
4. HDFS Delegation Token (max life time = 7 days)
5. Block Access Token (shot time)

<font color="red">**Proglem: Applications on Yarn cannot run > 7 days**</font>

---
# How Spark solve the Problem

---
# Old Design
![](images/spark1.PNG)

<font color="red">**Problem: cannot run > 7 days on Yarn**</font>

---
# New Design from Spark-1.4.0
![](images/spark2.PNG)
From: [Long Running Spark Apps on Secure YARN](https://issues.apache.org/jira/secure/attachment/12693526/SparkYARN.pdf)

<font color="green">**Upload Keytab to HDFS and login from Keytab before token expired**</font>

[Spark-5342 Allow long running Spark apps to run on secure YARN/HDFS](https://issues.apache.org/jira/browse/SPARK-5342)

---
# Log Aggregation Token Expire Problem
**Configuring YARN for Long-running Applications (Hadoop 2.6.0)**

- [Configuring YARN for Long-running Applications](http://www.cloudera.com/content/www/en-us/documentation/enterprise/5-3-x/topics/cm_sg_yarn_long_jobs.html)
- [Yarn-2704  Localization and log-aggregation will fail if hdfs delegation token expired after token-max-life-time](https://issues.apache.org/jira/browse/YARN-2704)
- [Yarn-2704 Github](https://github.com/apache/hadoop/commit/a16d022ca4313a41425c8e97841c841a2d6f2f54?diff=split)

---
# Hadoop Kerberos Programming API

---
# UserGroupInformation (Hadoop)
    !java
    // Log a user in from a keytab file. Loads a user identity from a keytab
    // file and logs them in. They become the currently logged-in user.
    static void loginUserFromKeytab(String user, String path)

    // Log a user in from a keytab file. Loads a user identity from a keytab
    // file and login them in. This new user does not affect the currently
    static UserGroupInformation loginUserFromKeytabAndReturnUGI(String user,
                                                                String path)

    // Return the current user, including any doAs in the current stack.
    static UserGroupInformation getCurrentUser()

    // Re-login a user from keytab if TGT is expired or is close to expiry.
    void checkTGTAndReloginFromKeytab()

    // Add the given Credentials to this user.
    public void addCredentials(Credentials credentials)

    public Credentials getCredentials()

    // Run the given action as the user.
    public <T> T doAs(PrivilegedAction<T> action)

---
# UserGroupInformation Runtime

    !scala
    UserGroupInformation.loginUserFromKeytab(principal, keytab)
    val ugi = UserGroupInformation.getCurrentUser

![](images/ugi1.PNG)

---
# Subject (Java)
> A Subject represents a grouping of related information for a single entity, such as a person. Such information includes the Subject's identities as well as its security-related attributes (passwords and cryptographic keys, for example).


---
# Subject Runtime
    !scala
    val ugi = UserGroupInformation.getCurrentUser

![](images/ugi2.PNG)


---
# Subject.doAs

    !java
    /**
     * Perform work as a particular Subject.
     *
     * This method first retrieves the current Thread's
     * AccessControlContext via AccessController.getContext,
     * and then instantiates a new AccessControlContext
     * using the retrieved context along with a new
     * SubjectDomainCombiner (constructed using the provided Subject).
     * Finally, this method invokes AccessController.doPrivileged,
     * passing it the provided PrivilegedAction,
     * as well as the newly constructed AccessControlContext.
     *
     * @param subject the Subject that the specified
     *        action will run as.  This parameter may be null.
     */
    public static <T> T doAs(final Subject subject,
                        final java.security.PrivilegedAction<T> action)

---
# Use Cases

---
# Kerberos Configuration
    !scala
    System.setProperty("java.security.krb5.realm", "HADOOP.QIYI.COM")
    System.setProperty("java.security.krb5.kdc", "hadoop-kdc01")

---
# Use Case 1: kinit by crontab
Run once every day in crontab

    !bash
    kinit -l 3d -k -t ~/test.keytab test@HADOOP.QIYI.COM

<font color="green">Right:</font>

    !scala
    val fs = FileSystem.get(new Configuration())
    while (true) {
      println(fs.listFiles(new Path("/user"), false))
      Thread.sleep(60 * 1000)
    }

**Kerberos will relogin automatically, when token is expired**

---
# Use Case 2: Login with Keytab File
<font color="green">Right:</font>

    !scala
    UserGroupInformation.loginUserFromKeytab(principal, keytab)
    val fs = FileSystem.get(new Configuration())
    while (true) {
      println(fs.listFiles(new Path("/user"), false))
      Thread.sleep(60 * 1000)
    }

**Kerberos will relogin automatically, when token is expired**

<font color="red">Wrong:</font>

    !scala
    UserGroupInformation.loginUserFromKeytab(principal, keytab)
    val fs = FileSystem.get(new Configuration())
    while (true) {
      UserGroupInformation.loginUserFromKeytab(principal, keytab)
      println(fs.listFiles(new Path("/user"), false))
      Thread.sleep(60 * 1000)
    }

**Do <font color="red">NOT</font> call UserGroupInformation.loginUserFromKeytab again**

---
# Use Case 3: Multi-User in Signle JVM
<font color="red">Wrong:</font>

    !scala
    val ugi = UserGroupInformation.loginUserFromKeytabAndReturnUGI(principal,
                                                                  keytab)
    ugi.doAs(new PrivilegedExceptionAction[Void] {
      override def run(): Void = {
        val fs = FileSystem.get(new Configuration())
        while (true) {
          println(fs.listFiles(new Path("/user"), false))
          Thread.sleep(60 * 1000)
        }
        null
      }
    })

**Kerberos will <font color="red">NOT</font> relogin automatically, when token is expired**

---
# Use Case 3: Muilti-User in Signle JVM (CONT.)
<font color="green">Right:</font>

    !scala
    val ugi = UserGroupInformation.loginUserFromKeytabAndReturnUGI(principal,
                                                                  keytab)
    ugi.doAs(new PrivilegedExceptionAction[Void] {
      override def run(): Void = {
        val fs = FileSystem.get(new Configuration())
        while (true) {
          UserGroupInformation.getCurrentUser.reloginFromKeytab()
          println(fs.listFiles(new Path("/user"), false))
          Thread.sleep(60 * 1000)
        }
        null
      }
    })

**Call reloginFromKeytab before token is expired**

---
# Use Case 4: Using HDFS Delegation Token (Yarn Application)
<font color="green">Right:</font>

    !scala
    val creds = new org.apache.hadoop.security.Credentials()
    val ugi = UserGroupInformation.loginUserFromKeytabAndReturnUGI(principal,
                                                                    keytab)
    ugi.doAs(new PrivilegedExceptionAction[Void] {
      override def run(): Void = {
        val fs = FileSystem.get(new Configuration())
        fs.addDelegationTokens("test", creds)
        null
      }
    })
    UserGroupInformation.getCurrentUser.addCredentials(creds)

**Update credentials periodically before token expired**

---
# References
- [The MIT Kerberos Administrator’s How-to Guide](http://www.kerberos.org/software/adminkerberos.pdf)
- [Hadoop Security Design](http://www.valleytalk.org/wp-content/uploads/2013/03/hadoop-security-design.pdf)
- [Long Running Spark Apps on Secure YARN](https://issues.apache.org/jira/secure/attachment/12693526/SparkYARN.pdf)

---
# Related Patches
### Spark-1.4.0
- [Spark-5342 Allow long running Spark apps to run on secure YARN/HDFS](https://issues.apache.org/jira/browse/SPARK-5342)
- [SPARK-6918 Secure HBase with Kerberos does not work over YARN](https://issues.apache.org/jira/browse/SPARK-6918)
### Spark-1.5.0
- [Spark-8688 Hadoop Configuration has to disable client cache when writing or reading delegation tokens](https://issues.apache.org/jira/browse/SPARK-8688)
- [Spark-7524 add configs for keytab and principal, move originals to internal](https://issues.apache.org/jira/browse/SPARK-7524)

### Submit Patches
- [Spark-11182 HDFS Delegation Token will be expired when calling "UserGroupInformation.getCurrentUser.addCredentials" in HA mode](https://issues.apache.org/jira/browse/SPARK-11182)
- [HDFS-9276 Failed to Update HDFS Delegation Token for long running application in HA mode](https://issues.apache.org/jira/browse/HDFS-9276)
