(import (cyclone openssl)
        (scheme base)
        (scheme write))

(begin
  (display (TLS_method))
  (display (TLS_client_method))
  (display (TLS_server_method)))
