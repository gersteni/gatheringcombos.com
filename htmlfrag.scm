#lang racket


(define insertbootstrap
  `(link ((rel "stylesheet")
          (href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css")
          (integrity "sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7")
          (crossorigin "anonymous"))))

(define head-charset `(meta ((charset "utf-8"))))

;; using the viewport recommendation from https://developers.google.com/speed/docs/insights/ConfigureViewport

(define head-viewport `(meta ((name "viewport") (content "width=device-width, initial-scale=1"))))

(define head-http-equiv `(meta ((http-equiv "X-UA-Compatible") (content "IE=edge"))))

(define footer 
  `(div ((class "row"))

        (div ((class "col-md-12"))
             (hr)
             "Say hi at  " 
             (a ((href "https://twitter.com/idoh")) "@idoh")
             " and "
             (a ((href "https://plus.google.com/+IdohGerstenx")) "Google+")
             " | " (a ((href "/about")) "About")
             " | " (a ((href "https://github.com/gersteni")) "Site's source code")
             " | " (a ((href "http://www.idoh.com")) "blog")
             (br))))

(provide (all-defined-out))
