;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname FinalProject) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders

;; ===================================================================
;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define BACKGROUND (empty-scene WIDTH HEIGHT))
(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer
(define INVADER-HALF-HEIGHT (/ 2(image-height INVADER)))
(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))
(define MISSILE (ellipse 5 15 "solid" "red"))
(define THRESHOLD (* (image-width INVADER) 2/3))

;; ===================================================================
;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition
#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))


(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1
(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))


(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick
(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right

#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates
(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))


;; ListOfInvader is one of:
;; - empty
;; - (cons Invader ListOfInvader)
;; interp. a list of invaders
(define LOI0 empty)
(define LOI1 (cons (make-invader(random WIDTH) 0 1.5) empty))
(define LOI2 (cons (make-invader(random WIDTH) 0 1.5) (cons (make-invader(random WIDTH) 0 1.5) empty)))
(define LOI3 (cons (make-invader(random WIDTH) 0 1.5)
                   (cons (make-invader(random WIDTH) 0 1.5)
                         (cons (make-invader(random WIDTH) 0 1.5) empty))))

#;
(define (fn-for-loinvader loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi))
              (fn-for-loinvader (rest loi)))]))

;; Tempalate rules used:
;; - one of: 2 cases
;; - atomic distinct: empty?
;; - compound: (cons Invader ListOfInvader)
;; - reference: (first loi)
;; - self-reference: (rest loi)


;; ListOfMissile is one of:
;; - empty
;; - (cons Missile ListOfMissile)
;; interp. a list of missiles
(define LOM0 empty)
(define LOM1 (cons M1 empty))
(define LOM2 (cons M1 (cons M2 (cons M3 empty))))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) (...)]
        [else
         (... (fn-for-missile (first lom))
              (fn-for-lom (rest lom)))]))

;; Template rules used:
;; - one of: 2 cases
;; - atomic distinct: empty?
;; - compound: (cons Missile ListOfMissile)
;; - reference: (first lom)
;; - self-reference: (rest lom)

(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; ===================================================================
;; Functions:

;; World -> World
;; start the world with (main G0)
;; 
(define (main w)
  (big-bang w                               ; World
    (on-tick   play-game)                   ; World -> World
    (to-draw   place-world)                 ; World -> Image
    (stop-when game-ends?)                  ; World -> Boolean
    (on-key    handle-key)))                ; World KeyEvent -> World


;; World -> World
;; moves/removes invaders, missiles and tank in the world.
;;               make invaders at random position
(check-random (play-game (make-game empty empty (make-tank 50 -1)))
              (make-game (random-invader-generate empty) empty
                         (make-tank (- 50 TANK-SPEED) -1)))
(check-random (play-game (make-game empty (cons (make-missile 100 0)
                                                (cons (make-missile 150 50) empty)) (make-tank 50 -1)))
              (make-game (random-invader-generate empty)
                         (cons (make-missile 150 (- 50 MISSILE-SPEED)) empty)
                         (make-tank (- 50 TANK-SPEED) -1)))
(check-random (play-game (make-game (cons (make-invader 150 0 1.5)
                                          (cons (make-invader 50 0 1.5)
                                                (cons (make-invader 210 0 1.5) empty)))
                                    empty (make-tank 50 -1)))
              (make-game (random-invader-generate (cons (make-invader (+ 150 INVADER-X-SPEED)
                                             (+ 0 INVADER-Y-SPEED)
                                             1.5)
                               (cons (make-invader (+ 50 INVADER-X-SPEED)
                                                   (+ 0 INVADER-Y-SPEED)
                                                   1.5)
                                     (cons (make-invader (+ 210 INVADER-X-SPEED)
                                                         (+ 0 INVADER-Y-SPEED)
                                                         1.5) empty))))
                         empty
                         (make-tank (- 50 TANK-SPEED)
                                    -1)))
(check-random (play-game (make-game (cons (make-invader 150 0 1.5)
                                          (cons (make-invader 50 0 1.5)
                                                (cons (make-invader 210 0 1.5) empty)))
                                    (cons (make-missile 50 0) empty)
                                    (make-tank 50 -1)))
              (make-game (random-invader-generate (cons (make-invader (+ 150 INVADER-X-SPEED)
                                             (+ 0 INVADER-Y-SPEED)
                                             1.5)
                               (cons (make-invader (+ 210 INVADER-X-SPEED)
                                                   (+ 0 INVADER-Y-SPEED)
                                                   1.5) empty)))
                         empty
                         (make-tank (- 50 TANK-SPEED)
                                    -1)))

#;
(define (play-game w) w) ;stub

;<template as function composition>
(define (play-game w)
  (make-game (move-LOI-xy-on-tick (overlapping-invader? (game-missiles w)
                                                        (random-invader-generate (game-invaders w))))
             (next-missile        (overlapping-missile? (game-missiles w)
                                                        (game-invaders w)))
             (move-tank-x-on-tick (game-tank w))))



;; ListOFMissile -> ListOfMissile
;; create a random LOI at top of the screen at random location x.
;;        append the current created LOI to the given list or empty when starting the game
;;        e.g (main (make-game (cons (make-invader (random WIDTH) 0 1.5) empty) empty (make-tank 250 -1)))
;;        e.g (main (make-game empty empty (make-tank 250 -1)))
(check-random (random-invader-generate (cons (make-invader (random WIDTH) 0 1.5) empty))
              (cons (make-invader (random WIDTH) 0 1.5) empty))
(check-random (random-invader-generate (cons (make-invader (random WIDTH) 0 1.5) empty))
              (append (cons (make-invader (random WIDTH) 0 1.5) empty) (generate-loi (random 1000))))
(check-random (random-invader-generate (cons (make-invader (random WIDTH) 0 1.5)
                                             (cons (make-invader (random WIDTH) 0 1.5)
                                                   (cons (make-invader (random WIDTH) 0 1.5) empty))))
              (append (cons (make-invader (random WIDTH) 0 1.5)
                            (cons (make-invader (random WIDTH) 0 1.5)
                                  (cons (make-invader (random WIDTH) 0 1.5) empty)))
                      (generate-loi (random 1000))))
(check-random (random-invader-generate (cons (make-invader (random WIDTH) 0 1.5)
                                             (cons (make-invader (random WIDTH) 0 1.5)
                                                   (cons (make-invader (random WIDTH) 0 1.5)
                                                         (cons (make-invader (random WIDTH) 0 1.5) empty)))))
              (append (cons (make-invader (random WIDTH) 0 1.5)
                            (cons (make-invader (random WIDTH) 0 1.5)
                                  (cons (make-invader (random WIDTH) 0 1.5)
                                        (cons (make-invader (random WIDTH) 0 1.5) empty))))
                      (generate-loi (random 1000))))
              
#;
(define (random-invader-generate loi) loi) ;stub

;<template as function composition>
(define (random-invader-generate loi)
  (append loi (generate-loi (random 1000))))
            
            

;; Number -> ListOfInvaders
;; create a LOI based on the random number it receives, otherwise empty
;;        n is the (random 1000)
(check-random (generate-loi 139)  empty)
(check-random (generate-loi 346) (cons (make-invader (random WIDTH) 0 1.5)
                                       (cons (make-invader (random WIDTH) 0 1.5) empty)))
(check-random (generate-loi 745) (cons (make-invader (random WIDTH) 0 1.5) empty))

#;
(define (generate-loi n) empty) ;stub

;<took template from LOI>
(define (generate-loi n)
  (cond [(and (> n 140)
              (< n 150)) (cons (make-invader (random WIDTH) 0 1.5) empty)]
        [(and (> n 345)
              (< n 350)) (cons (make-invader (random WIDTH) 0 1.5)
                               (cons (make-invader (random WIDTH) 0 1.5) empty))]
        [(and (> n 740)
              (< n 750)) (cons (make-invader (random WIDTH) 0 1.5)  empty)]
        [else
         empty]))



;; Ivader -> Invader 
;; increase or decrese x and y possition of INVADER by INVADER-X-SPEED or INVADER-Y-SPEED
(check-expect (move-invader-xy-on-tick (make-invader 150 100 1.5))
              (make-invader (+ 150 INVADER-X-SPEED)
                            (+ 100 INVADER-Y-SPEED)
                            1.5))
(check-expect (move-invader-xy-on-tick (make-invader 150 100 -1.5))
              (make-invader (- 150 INVADER-X-SPEED)
                            (+ 100 INVADER-Y-SPEED)
                            -1.5))
#;
(define (move-invader-xy-on-tick i) i) ;stub

;<took template from INVADER>
(define (move-invader-xy-on-tick i)
  (cond [(> (+ (invader-x i) (invader-dx i)) WIDTH)
         (make-invader WIDTH (+ (invader-y i) INVADER-Y-SPEED) (- (invader-dx i)))]
        [(< (+ (invader-x i) (invader-dx i)) 0)
         (make-invader 0 (+ (invader-y i) INVADER-Y-SPEED) (- (invader-dx i)))]
        [else
         (make-invader (+ (invader-x i) (invader-dx i))
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (invader-dx i))]))



;; ListOfInvader -> ListOfInvader
;; produce the next LOI on x and y position by giving move-invader-xy-on-tick
(check-expect (move-LOI-xy-on-tick (cons (make-invader 150 0 1.5)
                                         (cons (make-invader 50 0 1.5)
                                               (cons (make-invader 210 0 1.5) empty))))
              (cons (make-invader (+ 150 INVADER-X-SPEED)
                                  (+ 0 INVADER-Y-SPEED)
                                  1.5)
                    (cons (make-invader (+ 50 INVADER-X-SPEED)
                                        (+ 0 INVADER-Y-SPEED)
                                        1.5)
                          (cons (make-invader (+ 210 INVADER-X-SPEED)
                                              (+ 0 INVADER-Y-SPEED)
                                              1.5) empty))))

#;
(define (move-LOI-xy-on-tick loi) loi) ;stub

; took template from LOI
(define (move-LOI-xy-on-tick loi)
  (cond [(empty? loi) empty]
        [else
         (cons (move-invader-xy-on-tick (first loi))
               (move-LOI-xy-on-tick (rest loi)))]))



;; Missile -> Missile
;; decrease y possition of MISSILE by MISSILE-SPEED
;;          e.g missile move from down to up
(check-expect (move-missile-y-on-tick (make-missile 150 300))
              (make-missile 150
                            (- 300 MISSILE-SPEED)))

#;
(define (move-missile-y-on-tick m) m) ;stub

; took template from MISSILE
(define (move-missile-y-on-tick m)
  (make-missile (missile-x m)(- (missile-y m) MISSILE-SPEED)))



;; ListOfMissile -> ListOfMissile
;; produce the next LOM on y position by giving move-missile-y-on-tick
(check-expect (move-LOM-y-on-tick (cons (make-missile 250 300) empty))
              (cons (move-missile-y-on-tick (make-missile 250 300)) empty))
(check-expect (move-LOM-y-on-tick (cons (make-missile 250 300)
                                        (cons (make-missile 50 300)empty)))
              (cons (move-missile-y-on-tick (make-missile 250 300))
                    (cons (move-missile-y-on-tick (make-missile 50 300)) empty)))

#;
(define (move-LOM-y-on-tick lom) lom) ;stub

;<took template from LOM>
(define (move-LOM-y-on-tick lom)
  (cond [(empty? lom) empty]
        [else
         (cons (move-missile-y-on-tick (first lom))
               (move-LOM-y-on-tick (rest lom)))]))



;; ListOfMissile -> ListOfMissile
;; produce a LOM (decrease y possition of MISSILE by MISSILE-SPEED)
;;         remove missile that goes beyond screen HEIGHT      
(check-expect (next-missile (cons (make-missile 150 500)
                                  (cons (make-missile 160 500) empty)))
              (cons (make-missile 150 (- 500 MISSILE-SPEED))
                    (cons (make-missile 160 (- 500 MISSILE-SPEED)) empty)))
(check-expect (next-missile (cons (make-missile 150 0)
                                  (cons (make-missile 160 500) empty)))
              (cons (make-missile 160 (- 500 MISSILE-SPEED)) empty))

#;
(define (next-missile lom) lom)

;<template as function composition>
(define (next-missile lom)
  (over-board (move-LOM-y-on-tick lom)))



;; ListOfMissile -> ListOfMissile
;; removes a missile from the list if goes beyond game HEIGHT frame
;;         and produce an empty list if all missiles goes out of frame
(check-expect (over-board (cons (make-missile 160 -1) empty)) empty)
(check-expect (over-board (cons (make-missile 150 500) empty))
              (cons (make-missile 150 500) empty))
(check-expect (over-board (cons (make-missile 150 -1) (cons (make-missile 160 500) empty)))
              (cons (make-missile 160 500) empty))                                          ;first
(check-expect (over-board (cons (make-missile 150 500)
                                (cons (make-missile 160 -1)
                                      (cons (make-missile 170 500) empty))))
              (cons (make-missile 150 500) (cons (make-missile 170 500) empty)))            ;middle
(check-expect (over-board (cons (make-missile 150 500)
                                (cons (make-missile 160 -1) empty)))
              (cons (make-missile 150 500) empty))                                           ;last
                          
#;
(define (over-board lom) lom) ;stub

;<took template from LOM>
(define (over-board lom)
  (cond [(empty? lom) empty]
        [else
         (if (over? (first lom))
             (over-board (rest lom))
             (cons (first lom) (over-board (rest lom))))]))



;; Missile -> Boolean
;; produce true if missile is less than HEIGHT 0, false otherwise
(check-expect (over? (make-missile 150 500)) false)
(check-expect (over? (make-missile 150 -1)) true)

#;
(define (over? m) true) ;stub

;<took template from MISSILE>
(define (over? m)
  (< (missile-y m) 0))



;; Tank -> Tank
;; produce the next tank on x position defined by direction
(check-expect (move-tank-x-on-tick (make-tank 50  1)) (make-tank (+ 50 TANK-SPEED)  1))    ;middle
(check-expect (move-tank-x-on-tick (make-tank 50 -1)) (make-tank (- 50 TANK-SPEED) -1))

(check-expect (move-tank-x-on-tick (make-tank (- WIDTH TANK-SPEED) 1)) (make-tank WIDTH 1));reaches edge
(check-expect (move-tank-x-on-tick (make-tank 2          -1)) (make-tank 0    -1))

#;
(define (move-tank-x-on-tick t) t)

;<took template from TANK>
(define (move-tank-x-on-tick t)
  (if (positive? (tank-dir t))
      (cond [(> (+ (tank-x t) TANK-SPEED) WIDTH) (make-tank WIDTH (tank-dir t))]
            [else
             (make-tank (+ (tank-x t) TANK-SPEED) (tank-dir t))])
      (cond [(< (- (tank-x t) TANK-SPEED) 0) (make-tank 0 (tank-dir t))]
            [else
             (make-tank (- (tank-x t) TANK-SPEED) (tank-dir t))])))



;; ListMissile ListOfInvader -> ListOfMissile
;; determines whether the missile-location and invader-location are overlapping.
;;            returns a ListOfMissile (original or new list without the overlapped missile)
(check-expect (overlapping-missile? empty empty) empty)
(check-expect (overlapping-missile? empty (cons (make-invader 1000 0 1.5) empty)) empty)
(check-expect (overlapping-missile? (cons (make-missile 0 0) empty)
                                    (cons (make-invader 1000 0 1.5) empty))
              (cons (make-missile 0 0) empty))
(check-expect (overlapping-missile? (cons (make-missile 0 0)
                                          (cons (make-missile 100 250) empty))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 500 0 1.5) empty)))
              (cons (make-missile 0 0)
                    (cons (make-missile 100 250) empty)))
(check-expect (overlapping-missile? (cons (make-missile 0 0)
                                          (cons (make-missile 50 49)
                                                (cons (make-missile 100 250) empty)))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 51 51 1.5)
                                                (cons (make-invader 500 0 1.5) empty))))
              (cons (make-missile 0 0)
                    (cons (make-missile 100 250) empty)))
(check-expect (overlapping-missile? (cons (make-missile 50 49)
                                          (cons (make-missile 0 0)
                                                (cons (make-missile 100 250) empty)))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 251 151 1.5)
                                                (cons (make-invader 500 0 1.5)
                                                      (cons (make-invader 51 51 1.5) empty)))))
              (cons (make-missile 0 0)
                    (cons (make-missile 100 250) empty)))
(check-expect (overlapping-missile? (cons (make-missile 0 0)
                                          (cons (make-missile 100 250)
                                                (cons (make-missile 50 49) empty)))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 51 51 1.5)
                                                (cons (make-invader 1000 0 1.5) empty))))
              (cons (make-missile 0 0)
                    (cons (make-missile 100 250) empty)))


#;
(define (overlapping-missile? missiles-loc invaders-loc) missiles-loc) ;stub

;<took template from LOM>
;<operate on arbitrary size data>
(define (overlapping-missile? missiles-loc invaders-loc)
  (cond [(empty? missiles-loc) empty]
        [else
         (if (check-overlapping-missile? invaders-loc (first missiles-loc))
             (rest missiles-loc) 
             (cons (first missiles-loc) (overlapping-missile? (rest missiles-loc) invaders-loc )))]))



;; ListMissile ListOfInvader -> ListOfInvader
;; determines whether the missile-location and invader-location are overlapping.
;;            returns a ListOfInvader (original or new list without the hit invader)
(check-expect (overlapping-invader? empty empty) empty)
(check-expect (overlapping-invader? (cons (make-missile 0 0) empty) empty) empty)
(check-expect (overlapping-invader? (cons (make-missile 0 0) empty)
                                    (cons (make-invader 1000 0 1.5) empty))
              (cons (make-invader 1000 0 1.5) empty))
(check-expect (overlapping-invader? (cons (make-missile 0 0)
                                          (cons (make-missile 100 250) empty))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 500 0 1.5) empty)))
              (cons (make-invader 1000 0 1.5)
                    (cons (make-invader 500 0 1.5) empty)))
(check-expect (overlapping-invader? (cons (make-missile 0 0)
                                          (cons (make-missile 50 49)
                                                (cons (make-missile 100 250) empty)))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 51 51 1.5)
                                                (cons (make-invader 500 0 1.5) empty))))
              (cons (make-invader 1000 0 1.5)
                    (cons (make-invader 500 0 1.5) empty)))
(check-expect (overlapping-invader? (cons (make-missile 0 0)
                                          (cons (make-missile 50 49)
                                                (cons (make-missile 100 250) empty)))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 251 151 1.5)
                                                (cons (make-invader 500 0 1.5)
                                                      (cons (make-invader 51 51 1.5) empty)))))
              (cons (make-invader 1000 0 1.5)
                    (cons (make-invader 251 151 1.5)
                          (cons (make-invader 500 0 1.5) empty))))
(check-expect (overlapping-invader? (cons (make-missile 0 0)
                                          (cons (make-missile 100 250)
                                                (cons (make-missile 50 49) empty)))
                                    (cons (make-invader 1000 0 1.5)
                                          (cons (make-invader 51 51 1.5)
                                                (cons (make-invader 1000 0 1.5) empty))))
              (cons (make-invader 1000 0 1.5)
                    (cons (make-invader 1000 0 1.5) empty)))

#;
(define (overlapping-invader? missiles-loc invaders-loc) invaders-loc) ;stub

;<took template from LOI>
;<operate on arbitrary size data>
(define (overlapping-invader? missiles-loc invaders-loc)
  (cond [(empty? invaders-loc) empty]
        [else
         (if (check-overlapping-invader? missiles-loc (first invaders-loc))
             (rest invaders-loc) 
             (cons (first invaders-loc) (overlapping-invader? missiles-loc (rest invaders-loc))))]))



;; ListOfInvader Missile -> Boolean
;; check LOI against an Missile to determine if they are overlapping.
;;       true means check until return true or false otherwise
(check-expect (check-overlapping-missile? (cons (make-invader 1000 0 1.5)
                                                (cons (make-invader 1000 0 1.5)
                                                      (cons (make-invader 1000 0 1.5) empty)))
                                          (make-missile 50 20)) 
              false)
(check-expect (check-overlapping-missile? (cons (make-invader 1000 0 1.5)
                                                (cons (make-invader 51 51 1.5)
                                                      (cons (make-invader 1000 0 1.5) empty)))
                                          (make-missile 50 49)) 
              true)

#;       
(define (check-overlapping-missile? loi missile) true) ;stub

;<took template from LOI>
(define (check-overlapping-missile? loi missile)
  (cond [(empty? loi) false]
        [else
         (if (< (distance missile (first loi)) THRESHOLD)
             true
             (check-overlapping-missile? (rest loi) missile))]))




;; ListOfMissile Invader -> Boolean
;; check LOM against an INVADER to determine if they are overlapping.
;;       true means check until return true or false otherwise
(check-expect (check-overlapping-invader? (cons (make-missile 0 0)
                                                (cons (make-missile 100 250)
                                                      (cons (make-missile 50 49) empty)))
                                          (make-invader 1000 0 1.5))
                                       
              false)
(check-expect (check-overlapping-invader? (cons (make-missile 0 0)
                                                (cons (make-missile 100 250)
                                                      (cons (make-missile 50 49) empty)))
                                          (make-invader 51 51 1.5))
              true)

#;          
(define (check-overlapping-invader? lom invader) true) ;stub

(define (check-overlapping-invader? lom invader)
  (cond [(empty? lom) false]
        [else
         (if (< (distance (first lom) invader) THRESHOLD)
             true
             (check-overlapping-invader? (rest lom) invader))]))

;; Missile Invader -> Number
;; computes the distance between missile and invader.
(check-expect (distance (make-missile 0 0) (make-invader 0 0 1.5)) 0)
(check-expect (distance (make-missile 1 0) (make-invader 1 1 1.5)) 1)
(check-within (distance (make-missile 0 0) (make-invader 1 1 1.5)) (sqrt 2) 1/1000000)

#;
(define (distance m i) 0) ;stub

(define (distance m i)
  (sqrt (+ (sqr (- (missile-x m) (invader-x i)))
           (sqr (- (missile-y m) (invader-y i))))))



;; ListOfInvader -> Image
;; place a list of INVADER whose x-y-posn is x y onto BACKGROUND
;;       <LOI IS THE LAST IMAGE PLACED TO BACKGROUND>
(check-expect (place-invader-xy (cons (make-invader 150 0 1.5)
                                      (cons (make-invader 250 0 1.5)
                                            (cons (make-invader 50 0 1.5) empty))))
              (place-image INVADER
                           150
                           0
                           (place-image INVADER
                                        250
                                        0
                                        (place-image INVADER
                                                     50
                                                     0
                                                     BACKGROUND))))
#;                         
(define (place-invader-xy loi) empty-image) ;stub

;<took template from LOI>
(define (place-invader-xy loi)
  (cond [(empty? loi) BACKGROUND]
        [else
         (place-image INVADER
                      (invader-x (first loi))
                      (invader-y (first loi))
                      (place-invader-xy (rest loi)))]))



;; ListOfMissile Image -> Image
;; place LOM onto BACKGROUND
;;       image is the next image added to a list to be displayed on BACKGROUND
;;       <LOM IS THE SECOND IMAGE PLACED TO BACKGROUND>
(check-expect (place-missile (cons (make-missile 200 150)
                                   (cons (make-missile 100 50)
                                         (cons (make-missile 50 250) empty))) empty-image)
              (place-image MISSILE
                           200
                           150
                           (place-image MISSILE
                                        100
                                        50
                                        (place-image MISSILE
                                                     50
                                                     250
                                                     empty-image))))


#;
(define (place-missile lom image) empty-image) ;stub

;<took template from LOM>
(define (place-missile lom image)
  (cond [(empty? lom) image]
        [else
         (place-image MISSILE
                      (missile-x (first lom))
                      (missile-y (first lom))
                      (place-missile (rest lom) image))]))

   


;; Tank Image -> Image
;; place TANK onto BACKGROUND
;;       image is the next image added to be displayed on BACKGROUND
;;       <TANK IS THE FIRST IMAGE PLACED TO BACKGROUND>
(check-expect (place-tank-x (make-tank 50 -1) empty-image)
              (place-image TANK
                           50
                           (- HEIGHT TANK-HEIGHT/2)
                           empty-image))
(check-expect (place-tank-x (make-tank 50 1) empty-image)
              (place-image TANK
                           50
                           (+ HEIGHT TANK-HEIGHT/2)
                           empty-image))
                           
#;
(define (place-tank-x tank image) tank) ;stub

; took template from TANK
(define (place-tank-x tank image)
  (place-image TANK
               (tank-x tank)
               (- HEIGHT TANK-HEIGHT/2)
               image))


;; World -> Image
;; place TANK, MISSILE AND INVADER onto BACKGROUND
(check-expect (place-world (make-game (cons (make-invader 150 0 1.5)
                                            (cons (make-invader 250 0 1.5)
                                                  (cons (make-invader 50 0 1.5) empty)))
                                      (cons (make-missile 250 50) empty)
                                      (make-tank 50 -1)))
              (place-image TANK
                           50
                           (- HEIGHT TANK-HEIGHT/2)
                           (place-image MISSILE
                                        250
                                        50
                                        (place-image INVADER
                                                     150
                                                     0
                                                     (place-image INVADER
                                                                  250
                                                                  0
                                                                  (place-image INVADER
                                                                               50
                                                                               0
                                                                               BACKGROUND))))))

#;
(define (place-world w) w) ;stub

;<template as function composition>
(define (place-world w)
  (place-tank-x (game-tank w)
                (place-missile (game-missiles w)
                               (place-invader-xy (game-invaders w)))))
                


;; ListOfInvaders -> Boolean
;; determine whether or not INVADER has reached END of HEIGHT
(check-expect (reach-end? (cons (make-invader 50 0 1.5)
                                (cons (make-invader 150 50 1.5)
                                      (cons (make-invader 150 150 1.5) empty)))) false)
(check-expect (reach-end? (cons (make-invader 150 (- HEIGHT INVADER-HALF-HEIGHT) 1.5)
                                (cons (make-invader 150 50 1.5)
                                      (cons (make-invader 50 150 1.5) empty)))) true)
(check-expect (reach-end? (cons (make-invader 150 0 1.5)
                                (cons (make-invader 150 HEIGHT 1.5)
                                      (cons (make-invader 150 0 1.5) empty)))) true)

#;
(define (reach-end? loi) true) ;stub

;<took template from LOI>
(define (reach-end? loi)
  (cond [(empty? loi) false]
        [else
         (if (>= (invader-y (first loi)) (- HEIGHT INVADER-HALF-HEIGHT))
             true
             (reach-end? (rest loi)))]))



;; World -> Boolean
;; determine whether or not to end the game
;;           true means an invader was not successfully destroyed and reached end of HEIGHT
;;           false means is destroyed or still alive but not reached end of HEIGHT
(check-expect (game-ends? (make-game (cons (make-invader 150 250 1.5)
                                           (cons (make-invader 50 150 1.5)
                                                 (cons (make-invader 250 200 1.5) empty)))
                                     (make-missile 250 400) (make-tank 250 -1)))
              false)
(check-expect (game-ends? (make-game (cons (make-invader 150 250 1.5)
                                           (cons (make-invader 50 150 1.5)
                                                 (cons (make-invader 250 HEIGHT 1.5) empty)))
                                     (make-missile 250 400) (make-tank 250 -1)))
              true)

#;
(define (game-ends? w) true) ;stub

;<template as function composition>
(define (game-ends? w)
  (cond [(reach-end? (game-invaders w)) true]
        (else
         false)))



;; World KeyEvent -> World
;; change or keep tank direction to the left when press "left"
;; change or keep tank direction to the right when pressed "right"
;;        when space is pressed create a missile at TANK location
(check-expect (handle-key (make-game I1 M1 (make-tank 50  1)) "left")
              (make-game I1 M1 (make-tank 50 -1)))
(check-expect (handle-key (make-game I1 M1 (make-tank 50 -1)) "left")
              (make-game I1 M1 (make-tank 50 -1)))
(check-expect (handle-key (make-game I1 M1 (make-tank 50  1)) "right")
              (make-game I1 M1 (make-tank 50 1)))
(check-expect (handle-key (make-game I1 M1 (make-tank 50  -1)) "right")
              (make-game I1 M1 (make-tank 50 1)))
(check-expect (handle-key (make-game I1 M1 T1) "up")
              (make-game I1 M1 T1))
(check-expect (handle-key (make-game I1 empty (make-tank 50 -1)) " ")
              (make-game I1
                         (cons (make-missile 50
                                             (- (- HEIGHT TANK-HEIGHT/2) 5)) empty)
                         (make-tank 50 -1)))

#;
(define (handle-key w key) w) ;stub

(define (handle-key w ke)
  (cond [(key=? ke "left")
         (if (negative? (tank-dir (game-tank w)))
             w
             (make-game (game-invaders w)
                        (game-missiles w)
                        (make-tank (tank-x (game-tank w)) (- (tank-dir (game-tank w))))))]
        [(key=? ke "right")
         (if (negative? (tank-dir (game-tank w)))
             (make-game (game-invaders w)
                        (game-missiles w)
                        (make-tank (tank-x (game-tank w)) (- (tank-dir (game-tank w)))))
             w)]
        [(key=? ke " ")
         (make-game (game-invaders w)
                    (cons (make-missile (tank-x (game-tank w))
                                        (- (- HEIGHT TANK-HEIGHT/2) 5)) (game-missiles w))
                    (game-tank w))]
        [else 
         w]))






(main G0)
