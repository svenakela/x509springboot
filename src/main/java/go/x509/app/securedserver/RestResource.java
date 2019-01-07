package go.x509.app.securedserver;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/")
public class RestResource {

  @GetMapping(value = "hello")
  public String hello() {
    return "Worldz!";
  }

}
