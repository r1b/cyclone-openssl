(define-library
  (cyclone openssl)
  (include-c-header "<openssl/ssl.h>")
  (export
    TLS_method
    TLS_client_method
    TLS_server_method)
  (c-linker-options "-lssl")
  (begin
    (c-define-type SSL_METHOD opaque)
    (c-define TLS_method SSL_METHOD "TLS_client_method")
    (c-define TLS_client_method SSL_METHOD "TLS_client_method")
    (c-define TLS_server_method SSL_METHOD "TLS_server_method")))
