#lang htdp/bsl
(require test-engine/racket-tests)
;; hp-family-tree-solution.rkt

;; Data definitions:

(define-struct wiz (name wand patronus kids))
;; Wizard is (make-wiz String String String ListOfWizard)
;; interp. a wizard in a descendant family tree
;;         name is the first name
;;         wand is the wood their primary wand is made of ("" if unknown)
;;         patronus is a string  ("" if unknown)
;;         kids is their immediate children

;;
;; ListOfWizard is one of:
;;  - empty
;;  - (cons Wizard ListOfWizard)
;; interp. a list of wizards

(define ARTHUR
  (make-wiz "Arthur" "" "Weasel"
            (list (make-wiz "Bill" "" "" (list (make-wiz "Victoire"  "" "" empty)
                                               (make-wiz "Dominique" "" "" empty)
                                               (make-wiz "Louis"     "" "" empty)))
                  (make-wiz "Charlie" "ash" "" empty)
                  (make-wiz "Percy" "" "" (list (make-wiz "Molly" "" "" empty)
                                                (make-wiz "Lucy"  "" "" empty)))
                  (make-wiz "Fred"    ""    "" empty)
                  (make-wiz "George"  ""    "" (list (make-wiz "Fred" "" "" empty)
                                                     (make-wiz "Roxanne"  "" "" empty)))
                  (make-wiz "Ron"     "ash" "Jack Russell Terrier" (list (make-wiz "Rose" "" "" empty)
                                                                         (make-wiz "Hugo" "" "" empty)))
                  (make-wiz "Ginny"   ""    "horse"
                            (list (make-wiz "James" "" "" empty)
                                  (make-wiz "Albus" "" "" empty)
                                  (make-wiz "Lily"  "" "" empty))))))
#;#;
(define (fn-for-wizard w)
  (... (wiz-name w)
       (wiz-wand w)
       (wiz-patronus w)
       (fn-for-low (wiz-kids w))))

(define (fn-for-low low)
  (cond [(empty? low) (...)]
        [else
         (... (fn-for-wizard (first low))
              (fn-for-low (rest low)))]))



;; ListOfPair is one of:
;;  - empty
;;  - (cons (list String String) ListOfPair)
;; interp. used to represent an arbitrary number of pairs of strings
(define LOP1 empty)
(define LOP2 (list (list "Harry" "stag") (list "Hermione" "otter")))
#;
(define (fn-for-lop lop)
  (cond [(empty? lop) (...)]
        [else
         (... (first (first lop))
              (second (first lop)) ;(first (rest (first lop)))
              (fn-for-lop (rest lop)))]))


;; ListOfString is one of:
;; - empty
;; - (cons String ListOfString)
;; interp. a list of strings
(define LOS1 empty)
(define LOS2 (list "a" "b"))

(define (fn-for-los los)
  (cond [(empty? los) ...]
        [else
         (... (first los)
              (fn-for-los (rest los)))]))

;; Functions

;; Wizard -> ListOfPair
;; ListOfWizard -> ListOfPair
;; produce every wizard in tree together with their patronus
(check-expect (patroni--low empty) empty)
(check-expect (patroni--wiz (make-wiz "a" "b" "c" empty)) (list (list "a" "c")))
(check-expect (patroni--wiz ARTHUR)
              (list
               (list "Arthur" "Weasel")
               (list "Bill" "")
               (list "Victoire" "")
               (list "Dominique" "")
               (list "Louis" "")
               (list "Charlie" "")
               (list "Percy" "")
               (list "Molly" "")
               (list "Lucy" "")
               (list "Fred" "")
               (list "George" "")
               (list "Fred" "")
               (list "Roxanne" "")
               (list "Ron" "Jack Russell Terrier")
               (list "Rose" "")
               (list "Hugo" "")
               (list "Ginny" "horse")
               (list "James" "")
               (list "Albus" "")
               (list "Lily" "")))

;<templates taken from Wizard and ListOfWizard>

(define (patroni--wiz w)
  (cons (list (wiz-name w)
              (wiz-patronus w))
        (patroni--low (wiz-kids w))))

(define (patroni--low low)
  (cond [(empty? low) empty]
        [else
         (append (patroni--wiz (first low))
                 (patroni--low (rest low)))]))

;; Wizard String -> ListOfString
;; ListOfWizard String -> ListOfString
;; produce names of all descendants whose wand is made of given wood (including wiz)
(check-expect (has-wand-of-wood--low empty "x") empty)
(check-expect (has-wand-of-wood--wiz (make-wiz "a" "b" "c" empty) "x") empty)
(check-expect (has-wand-of-wood--wiz (make-wiz "a" "b" "c" empty) "b") (list "a"))
(check-expect (has-wand-of-wood--wiz ARTHUR "ash") (list "Charlie" "Ron"))

;<templates taken from Wizard and ListOfWizard, with added atomic parameter>

(define (has-wand-of-wood--wiz w wood)
  (if (string=? (wiz-wand w) wood)
      (cons (wiz-name w)
            (has-wand-of-wood--low (wiz-kids w) wood))
      (has-wand-of-wood--low (wiz-kids w) wood)))

(define (has-wand-of-wood--low low wood)
  (cond [(empty? low) empty]
        [else
         (append (has-wand-of-wood--wiz (first low) wood)
                 (has-wand-of-wood--low (rest low) wood))]))

(test)
