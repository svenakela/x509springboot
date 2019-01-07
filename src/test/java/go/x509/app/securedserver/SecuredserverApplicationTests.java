package go.x509.app.securedserver;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.client.RestClientException;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = SecuredserverApplication.class,
    webEnvironment = WebEnvironment.RANDOM_PORT)
public class SecuredserverApplicationTests {

  @LocalServerPort
  private int port;

  @Test
  public void getRequestAndExpectOk() throws RestClientException, Exception {

    final var url = String.format("https://localhost:%d/hello", port);

    final var response = SslRequestHelper.restTemplate().exchange(url, HttpMethod.GET,
        SslRequestHelper.httpEntity(), String.class);

    Assert.assertEquals(HttpStatus.OK, response.getStatusCode());
    Assert.assertEquals("Worldz!", response.getBody());
  }

}

