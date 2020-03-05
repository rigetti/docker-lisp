(ql:quickload :drakma)

(defun https-fetch (url file &key (follow-redirects t) quietly
                               (if-exists :rename-and-delete)
                               (maximum-redirects ql-http:*maximum-redirects*))
  (declare (ignore follow-redirects quietly maximum-redirects if-exists))
  (let ((response (drakma:http-request url :force-binary t )))
    (with-open-file (s file :direction :output :if-exists :supersede :if-does-not-exist :create
                            :element-type '(unsigned-byte 8))
      (write-sequence response s)))
  nil)

(setf ql-http:*fetch-scheme-functions*
      (append ql-http:*fetch-scheme-functions*
              '(("https" . https-fetch))))

(ql-dist:install-dist "https://quicklisp.infra.rigetti.com:443/quantumlisp.txt"
                      :prompt nil)
