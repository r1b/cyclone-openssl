# Where is openssl on my machine?

```bash
dpkg-query -L libssl1.1
<SNIP>
/usr/lib/x86_64-linux-gnu/libcrypto.so.1.1
/usr/lib/x86_64-linux-gnu/libssl.so.1.1
<SNIP>
```

# What symbols are exported by libcrypto/libssl?

```bash
nm -D /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 | awk '{ if ($2 == "T") print $3 }'
<LOTS OF OUTPUT>
nm -D /usr/lib/x86_64-linux-gnu/libssl.so.1.1 | awk '{ if ($2 == "T") print $3 }'
<A LITTLE LESS OUTPUT>
```

# How do I initialize libssl?

Chicken does:

```scheme
(foreign-code #<<EOF
ERR_load_crypto_strings();
SSL_load_error_strings();
SSL_library_init();

#ifdef _WIN32
  RAND_screen();
  #endif

  EOF
  )
```

Racket does:

```scheme
(when ssl-available?
  ;; Make sure only one place tries to initialize OpenSSL,
  ;; and wait in case some other place is currently initializing
  ;; it.
  (begin
    (start-atomic)
    (let* ([done (ptr-add #f 1)]
           [v (register-process-global #"OpenSSL-support-initializing" done)])
      (if v
          ;; Some other place is initializing:
          (begin
            (end-atomic)
            (let loop ()
              (unless (register-process-global #"OpenSSL-support-initialized" #f)
                (sleep 0.01) ;; busy wait! --- this should be rare
                (loop))))
          ;; This place must initialize:
          (begin
            (SSL_library_init)
            (SSL_load_error_strings)
            (register-process-global #"OpenSSL-support-initialized" done)
            (end-atomic))))))
```

Racket also notes:

```scheme
(define-ssl SSL_library_init (_fun -> _void)
  ;; No SSL_library_init for 1.1 or later:
  #:fail (lambda () void))
(define-ssl SSL_load_error_strings (_fun -> _void)
  ;; No SSL_load_error_strings for 1.1 or later:
  #:fail (lambda () void))
```

So it seems like:

1. We don't have to worry about this yet.
2. Thread-safety is an ongoing concern.

These libraries are not **littered** with mutexes but there do appear to be a
few areas where it matters.

# Of those symbols exported by libcrypto / libssl, what is the minimal set required to realize this library?

In racket, we can look for calls to `(define-crypto)` and `(define-ssl)`.
In chicken, we can look for `(foreign-lambda)` and their ilk.

TODO: Enumerate

# Which functionality exposed by these scheme interfaces is a good MVP candidate?

1. A trivial task would be to dump supported client / server protocols. Probably a good "get your feet wet" task.
2. A useful foundational task would be to construct client / server contexts.
