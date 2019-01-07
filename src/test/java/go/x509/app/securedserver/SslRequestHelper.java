package go.x509.app.securedserver;

import javax.net.ssl.SSLContext;
import org.apache.http.client.HttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.util.ResourceUtils;
import org.springframework.web.client.RestTemplate;

public final class SslRequestHelper {

  private SslRequestHelper() {
    // no, this is static helper class.
  }

  private final static char[] storePwd = "+NSJ3KDtfEpoDg==".toCharArray();
  private final static char[] keyPwd = "+NSJ3KDtfEpoDg==".toCharArray();
  private final static String VALID_CRT = "classpath:client.jks";

  public static RestTemplate restTemplate() throws Exception {
    return restTemplate(getContext(VALID_CRT));
  }

  @SuppressWarnings("rawtypes")
  public static HttpEntity httpEntity() {
    return new HttpEntity<>(null, new HttpHeaders());
  }

  private static SSLContext getContext(final String certPath) throws Exception {
    final SSLContext sslContext = SSLContextBuilder.create()
        .loadKeyMaterial(ResourceUtils.getFile(certPath), storePwd, keyPwd)
        .loadTrustMaterial(ResourceUtils.getFile(certPath), storePwd).build();
    return sslContext;
  }

  private static RestTemplate restTemplate(final SSLContext sslContext) {
    final HttpClient client = HttpClients.custom().setSSLContext(sslContext).build();
    return new RestTemplate(new HttpComponentsClientHttpRequestFactory(client));
  }

}
