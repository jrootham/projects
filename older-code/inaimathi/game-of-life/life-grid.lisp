;;; Adapted from the grid-based solution at 
;;;;;; http://rosettacode.org/wiki/Conway%27s_Game_of_Life#Common_Lisp

(defpackage :life-grid (:use :cl))
(in-package :life-grid)

(defun next-life (array &optional results)
  (let* ((dimensions (array-dimensions array))
         (results (or results (make-array dimensions :element-type 'bit))))
    (destructuring-bind (rows columns) dimensions
      (labels ((entry (row col)
                 "Return array(row,col) for valid (row,col) else 0."
                 (if (or (not (< -1 row rows))
                         (not (< -1 col columns)))
                   0
                   (aref array row col)))
               (neighbor-count (row col &aux (count 0))
                 "Return the sum of the neighbors of (row,col)."
                 (dolist (r (list (1- row) row (1+ row)) count)
                   (dolist (c (list (1- col) col (1+ col)))
                     (unless (and (eql r row) (eql c col))
                       (incf count (entry r c))))))
               (live-or-die? (current-state neighbor-count)
                 (if (or (and (eql current-state 1)
                              (<=  2 neighbor-count 3))
                         (and (eql current-state 0)
                              (eql neighbor-count 3)))
                   1
                   0)))
        (dotimes (row rows results)
          (dotimes (column columns)
            (setf (aref results row column)
                  (live-or-die? (aref array row column)
                                (neighbor-count row column)))))))))
 
(defun print-grid (grid &optional (out *standard-output*))
  (destructuring-bind (rows columns) (array-dimensions grid)
    (dotimes (r rows grid)
      (dotimes (c columns (terpri out))
        (write-char (if (zerop (aref grid r c)) #\+ #\#) out)))))
 
(defun run-life (&optional world (iterations 10) (out *standard-output*))
  (let* ((world (or world (make-array '(10 10) :element-type 'bit)))
         (result (make-array (array-dimensions world) :element-type 'bit)))
    (do ((i 0 (1+ i))) ((eql i iterations) world)
      (terpri out) (print-grid world out)
      (psetq world (next-life world result)
             result world))))

(defparameter *glider*
  (let ((w (make-array '(50 50) :element-type 'bit)))
    (loop for (x . y) in '((1 . 0) (2 . 1) (0 . 2) (1 . 2) (2 . 2))
       do (setf (aref w y x) 1))
    w))

(defparameter *gosper-glider-gun*
  (let ((w (make-array '(50 50) :element-type 'bit)))
    (loop for (x . y) in '((24 . 0) (22 . 1) (24 . 1) (12 . 2) (13 . 2) (20 . 2) (21 . 2) (34 . 2)
			   (35 . 2) (11 . 3) (15 . 3) (20 . 3) (21 . 3) (34 . 3) (35 . 3) (0 . 4) (1 . 4)
			   (10 . 4) (16 . 4) (20 . 4) (21 . 4) (0 . 5) (1 . 5) (10 . 5) (14 . 5) (16 . 5)
			   (17 . 5) (22 . 5) (24 . 5) (10 . 6) (16 . 6) (24 . 6) (11 . 7) (15 . 7)
			   (12 . 8) (13 . 8))
       do (setf (aref w y x) 1))
    w))