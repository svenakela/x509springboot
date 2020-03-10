# X.509 Spring Boot

[![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://forthebadge.com)

How to setup a client/server certificate in Spring Boot and how to create a self signed certificate for development. The certificates are generated and signed with a minimum set of tools, the bare minimum is the JDK tools only.

This example will work for local development and server testing. If you have an internal CA these certificates can also be used for production but that setup is up to you. The Spring Boot application itself will be configured the same way, it is just the trusting and signing of the certificates that will differ. 

This is mainly a setup for **Jetty**. Tomcat requires your certificates to be "trusted" and therefore the setup is a little bit different.

Certificate generation is influenced by [lightbend's Nginx setup](https://lightbend.github.io/ssl-config/CertificateGeneration.html).

## Tools Needed:

 * keytool, distributed with the JDK
 * Openssl to generate passwords. Can be replaced for less dependencies by flipping the two lines of password generation in the top of the scripts.
 
## Setup

### Generate Certificates
 * Edit the environment variables in the top of the script [x509server_process.sh](x509server_process.sh) if needed
 * Edit the environment variables in the top of the script [x509client_process.sh](x509client_process.sh)
 * Execute the [x509server_process.sh](x509server_process.sh) script
 * Execute the [x509client_process.sh](x509client_process.sh) script
 * Copy the `server name CA` and `server name` JKS-files to your [src/main/resources](src/main/resources) folder. If you did not change script variables:
 
```bash
   mv -f mysecuredserver*.jks src/main/resources/
```
 
 * Copy the `client.jks` file to your client's [src/main/resources](src/main/resources). In this example a Junit test acts as a client and the `client.jks` is moved to [src/test/resources](src/test/resources) to make it work.
 
```bash
   mv -f client.jks src/test/resources/
```

  * Take the password in the file `password_server_mysecuredserver` and update `application.properties` passwords.

### Code Config
 
 Spring Boot will add all things needed if you add the `spring-boot-starter-security` dependency to the [pom.xml](pom.xml).
 
 Update [application.properties](src/main/resources/application.properties) with correct password taken from the password file generated by the server script. Also make sure your JKS file names are correct and match the files you copied to the resources folder.
 
 Implement a `WebSecurityConfigurerAdapter`, in this example it is added as a 
 [WebSecurityConfig.java](src/main/java/go/x509/app/securedserver/WebSecurityConfig.java).
 
 Now, all your end points require a client certificate upon requests
 
### Test 

 The [Junit test](src/test/java/go/x509/app/securedserver/SecuredserverApplicationTests.java) and its [helper class](src/test/java/go/x509/app/securedserver/SslRequestHelper.java) are using the Apache Http Client library for simplicity. 
 
 If you created new certificates the helper class must be updated with the password taken from the `password_client` file that the client script generated.
 
 Now be happy panda!
 
 
 
