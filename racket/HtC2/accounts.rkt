;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname accounts) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

;; accounts-starter.rkt

(define-struct node (id name bal l r))
;; Accounts is one of:
;;  - false
;;  - (make-node Natural String Integer Accounts Accounts)
;; interp. a collection of bank accounts
;;   false represents an empty collection of accounts.
;;   (make-node id name bal l r) is a non-empty collection of accounts such that:
;;    - id is an account identification number (and BST key)
;;    - name is the account holder's name
;;    - bal is the account balance in dollars CAD 
;;    - l and r are further collections of accounts
;; INVARIANT: for a given node:
;;     id is > all ids in its l(eft)  child
;;     id is < all ids in its r(ight) child
;;     the same id never appears twice in the collection

(define ACT0 false)
(define ACT1 (make-node 1 "Mr. Rogers"  22 false false))
(define ACT4 (make-node 4 "Mrs. Doubtfire"  -3
                        false
                        (make-node 7 "Mr. Natural" 13 false false)))
(define ACT3 (make-node 3 "Miss Marple"  600 ACT1 ACT4))
(define ACT42 
  (make-node 42 "Mr. Mom" -79
             (make-node 27 "Mr. Selatcia" 40 
                        (make-node 14 "Mr. Impossible" -9 false false)
                        false)
             (make-node 50 "Miss 604"  16 false false)))
(define ACT10 (make-node 10 "Dr. No" 84 ACT3 ACT42))

#;
(define (fn-for-act act)
  (cond [(false? act) (...)]
        [else
         (... (node-id act)
              (node-name act)
              (node-bal act)
              (fn-for-act (node-l act))
              (fn-for-act (node-r act)))]))

; ================================================================================
;PROBLEM 1:
;
;Design an abstract function (including signature, purpose, and tests) 
;to simplify the remove-debtors and remove-profs functions defined below.
;
;Now re-define the original remove-debtors and remove-profs functions 
;to use your abstract function. Remember, the signature and tests should 
;not change from the original functions.
; ================================================================================


;; (Accounts -> Boolean) Accounts -> Accounts
;; remove acts that meet a given predicate
(check-expect (local [(define (neg-bal? act) (negative? (node-bal act)))]
                (remove-acts neg-bal? (make-node 27 "Mr. Selatcia" 40
                          (make-node 14 "Mr. Impossible" -9 false false)
                          false)))
              (make-node 27 "Mr. Selatcia" 40 false false))

(define (remove-acts pred act)
  (cond [(false? act) false]
        [else
         (if (pred act)
             (join (remove-acts pred (node-l act))
                   (remove-acts pred (node-r act)))
             (make-node (node-id act)
                        (node-name act)
                        (node-bal act)
                        (remove-acts pred (node-l act))
                        (remove-acts pred (node-r act))))]))


;; Accounts -> Accounts
;; remove all accounts with a negative balance
(check-expect (remove-debtors (make-node 1 "Mr. Rogers" 22 false false)) 
              (make-node 1 "Mr. Rogers" 22 false false))

(check-expect (remove-debtors (make-node 14 "Mr. Impossible" -9 false false))
              false)

(check-expect (remove-debtors
               (make-node 27 "Mr. Selatcia" 40
                          (make-node 14 "Mr. Impossible" -9 false false)
                          false))
              (make-node 27 "Mr. Selatcia" 40 false false))

(check-expect (remove-debtors 
               (make-node 4 "Mrs. Doubtfire" -3
                          false 
                          (make-node 7 "Mr. Natural" 13 false false)))
              (make-node 7 "Mr. Natural" 13 false false))


(define (remove-debtors act)
  (local [(define (neg-bal? act) (negative? (node-bal act)))]
    (remove-acts neg-bal? act)))

#;
(define (remove-debtors act)
  (cond [(false? act) false]
        [else
         (if (negative? (node-bal act))
             (join (remove-debtors (node-l act))
                   (remove-debtors (node-r act)))
             (make-node (node-id act)
                        (node-name act)
                        (node-bal act)
                        (remove-debtors (node-l act))
                        (remove-debtors (node-r act))))]))


;; Accounts -> Accounts
;; Remove all professors' accounts.  
(check-expect (remove-profs (make-node 27 "Mr. Smith" 100000 false false)) 
              (make-node 27 "Mr. Smith" 100000 false false))
(check-expect (remove-profs (make-node 44 "Prof. Longhair" 2 false false)) false)
(check-expect (remove-profs (make-node 67 "Mrs. Dash" 3000
                                       (make-node 9 "Prof. Booty" -60 false false)
                                       false))
              (make-node 67 "Mrs. Dash" 3000 false false))
(check-expect (remove-profs 
               (make-node 97 "Prof. X" 7
                          false 
                          (make-node 112 "Ms. Magazine" 467 false false)))
              (make-node 112 "Ms. Magazine" 467 false false))

(define (remove-profs act)
  (local [(define (is-prof? act) (has-prefix? "Prof." (node-name act)))]
    (remove-acts is-prof? act)))

#;
(define (remove-profs act)
  (cond [(false? act) false]
        [else
         (if (has-prefix? "Prof." (node-name act))
             (join (remove-profs (node-l act))
                   (remove-profs (node-r act)))
             (make-node (node-id act)
                        (node-name act)
                        (node-bal act)
                        (remove-profs (node-l act))
                        (remove-profs (node-r act))))]))



;; String String -> Boolean
;; Determine whether pre is a prefix of str.
(check-expect (has-prefix? "" "rock") true)
(check-expect (has-prefix? "rock" "rockabilly") true)
(check-expect (has-prefix? "blues" "rhythm and blues") false)

(define (has-prefix? pre str)
  (string=? pre (substring str 0 (string-length pre))))

;; Accounts Accounts -> Accounts
;; Combine two Accounts's into one
;; ASSUMPTION: all ids in act1 are less than the ids in act2
(check-expect (join ACT42 false) ACT42)
(check-expect (join false ACT42) ACT42)
(check-expect (join ACT1 ACT4) 
              (make-node 4 "Mrs. Doubtfire" -3
                         ACT1
                         (make-node 7 "Mr. Natural" 13 false false)))
(check-expect (join ACT3 ACT42) 
              (make-node 42 "Mr. Mom" -79
                         (make-node 27 "Mr. Selatcia" 40
                                    (make-node 14 "Mr. Impossible" -9
                                               ACT3
                                               false)
                                    false)
                         (make-node 50 "Miss 604" 16 false false)))

(define (join act1 act2)
  (cond [(false? act2) act1]
        [else
         (make-node (node-id act2) 
                    (node-name act2)
                    (node-bal act2)
                    (join act1 (node-l act2))
                    (node-r act2))]))


; ================================================================================
;PROBLEM 2:

;Using your new abstract function, design a function that removes from a given
;BST any account where the name of the account holder has an odd number of
;characters.  Call it remove-odd-characters.
; ================================================================================

;; (Accounts -> Boolean) Accounts -> Accounts
;; interp. remove accounts where account ID is odd numbered
(check-expect (remove-odd-characters ACT1) false)
(check-expect (remove-odd-characters ACT4) (make-node 4 "Mrs. Doubtfire"  -3 false false))

(define (remove-odd-characters act)
  (local [(define (is-odd? act) (odd? (node-id act)))]
    (remove-acts is-odd? act)))

; ================================================================================
;Problem 3:

;Design an abstract fold function for Accounts called fold-act. 

;Use fold-act to design a function called charge-fee that decrements
;the balance of every account in a given collection by the monthly fee of 3 CAD.
; ================================================================================
;; (Natural String Integer X X -> X) X -> X 
;; fold function for Accounts
(define (fold-act fn b act)
  (cond [(false? act) b]
        [else
         (fn (node-id act)
              (node-name act)
              (node-bal act)
              (fold-act fn b (node-l act))
              (fold-act fn b (node-r act)))]))

;; Integer Accounts -> Accounts
;; interp. reduce the balance of every item in collection by 3
(check-expect (charge-fee 3 ACT1) (make-node 1 "Mr. Rogers"  19 false false))

(define (charge-fee fee act)
  (local [(define (charge id n bal lact ract)
          (make-node id n (- bal fee) lact ract))]
    (fold-act charge false act)))

; ================================================================================
;PROBLEM 4:

;Suppose you needed to design a function to look up an account based on its ID.
;Would it be better to design the function using fold-act, or to design the
;function using the fn-for-acts template?  Briefly justify your answer.
; ================================================================================

;; Using the fn-for-acts template, because fold-act will traverse the entire tree
;; even if the relevant ID is at the root of the tree. With fn-for-acts we can include
;; an escape expression if the ID is found early.