#lang racket


(require json)
(require racket/serialize)
(require net/uri-codec)
(require net/url)
(require web-server/servlet
         web-server/servlet-env)

;; run "raco pkg install anaphoric" if the package is missing
(require anaphoric)

(require "./model.scm")
(require "./htmlfrag.scm")

;; utils

(define c "")
(define (cize title)
  (set! c (hash-ref combodb title)))


;; dispatch

(define-values (site-dispatch site-url)
               (dispatch-rules
                 (("") main)
                 ))

(define (main req) (make-index-page req))

(define (start req)
  (site-dispatch req))



;; todo: need to exclude bindings of zero length
(define (grab-binding symbol req)
  (define binds (request-bindings req))
  (if (and (exists-binding? symbol binds)
           (non-empty-string? (extract-binding/single symbol binds)))
    
    (extract-binding/single symbol binds)
    #f))



;; todo: check to see if the ID is already take, and if it is generate a new one
(define (make-combo-hash cards desc)
  (define combo (make-hash))
  (hash-set! combo 'id (random 4294967087))
  (hash-set! combo 'cards cards)
  (hash-set! combo 'desc desc)
  combo

  )


(define (add-plusses card-list)
  (string-append
    (if (eq? 1 (length card-list))
      (car card-list)
      (string-append (car card-list)
                     " + "
                     (add-plusses (cdr card-list))))))

(define (display-combo combo)
  `(div ((class "tbd"))

        (h3 ((class "combo"))
            (a ((href ,(string-append "/combos/" (number->string (hash-ref combo 'id)))))
            ,(add-plusses (hash-ref combo 'cards))))

        ,(aif (hash-ref combo 'desc)
              `(p ,it)
              ""
              )))


(define (display-combos)
  `(div ((class "tbd"))
        (h2 "The list of combos so far")
        (p ,(string-append "There are "
                           (number->string (number-of-combos))
                           " combos right tracked right now."))
        ,@(map (lambda (x)
                 (display-combo (hash-ref combodb x)))
               (hash-keys combodb))))


(define (add-combo c)
  (hash-set! combodb (hash-ref c 'id) c)
  (save-combodb)
  c)


;; todo: the if statement should appear earlier
(define (handle-combo-post req)
  (define bindings (request-bindings req))
  (define cards (remove false? (map (lambda (x)
                                      (grab-binding x req))
                                    `(card-a card-b card-c card-d))))
  (if (and 
        (exists-binding? 'card-a bindings)
        (exists-binding? 'card-b bindings))
    (display-combo (add-combo  
                     (make-combo-hash (filter string? cards)
                                      (grab-binding 'description req))))

    "No post yet"))

(define (make-submit-combo-form)
  (define (make-card-input label id)
    `(div ((class "formgroup"))
          (label ((for ,id)) ,label)
          (input ((type "text")
                  (class "form-control")
                  (id ,id)
                  (name ,id)
                  (placeholder "Card Name")))))
  `(form ((id "sub"))
     ,(make-card-input "First Card" "card-a")
     ,(make-card-input "Second Card" "card-b")
     ,(make-card-input "Third Card" "card-c")
     ,(make-card-input "Fourth Card" "card-d")

     (div ((class "formgroup"))
          (label ((for "description")) "Description")
          (textarea ((class "form-control")
                     (id "description")
                     (name "description")
                     (placeholder "Combo description")
                     (form "sub")
                    (rows "5"))))

     (input ((type "submit")
             (class "btn btn-default")))))



(define (make-index-page req)
  (response/xexpr
    `(html
       (head
         ,head-charset ,head-viewport ,head-http-equiv

         ;; todo add this stuff in later
         ;; ,insertbootstrap  ,insertGA 
         ;;

         ,insertbootstrap

         (link ((rel "stylesheet") (href "style.css")))

         (title "Combo Central"))

       (body (div ((class "container main"))
                  (div ((class "row"))
                       (div ((class "col-md-12"))
                            (h1 "Combo Central")
                            ;; todo: this will be off by one after submitting a combo, need to add the card first then show this stat
                            (p "A list of combos in Magic The Gathering. The goal of this site is to give an easily searchable list of all the combos and strong synergies in the game.")
                            (hr)))
                  ,(handle-combo-post req)

                  ;; right now assuming a max of four card combos
                  
                  ,(make-submit-combo-form)

                  (hr)
                  ,(display-combos)
                  (hr)





                  ,footer)))))

(define (gogo) 
  (serve/servlet start
                 #:servlet-regexp #rx""
                 #:servlet-path "/"
                 #:listen-ip #f
                 #:command-line? #t
                 ;; if you run on port 80 then you need to "sudo racket" first
                 #:port 80

                 ;; to-do: fix this, should not be reading from the root directory

                 #:extra-files-paths (list  (build-path "./"))
                 ))
