;;; ido-f3 --- Utlilize ido-mode to find files in a predefined and cached folder.

;; Written by Dan Carmon, dan@carmon.org.il

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

(require 'cl)

(setq f3-projects-dir "~/dev") ; 'Projects-directory' from which projects are selected using f3-switch-project
(setq f3-find-command "find")  ; unix find command used to list files under a directory tree
(setq f3-extension-whitelist '(js rb json yml yaml html erb rake lua txt el coffee css scss sql sh)) ; possible file extension whitelist
(setq f3-blacklist-regexp "\\.git|1\\.9\\.") ; blacklist regexp

(defun f3-filter (list)
"Filter a file list using (1) f3-extension-whitelist and then (2) f3-blacklist-regexp"
  (let*
      ((after-whitelist
        (delete-if-not
         (lambda (file)
           (string-match
            (concat
             "\\(\/[a-zA-Z_]+\\)$"  ;; no extension at all
             "\\|\\(" ;;  (or)
             "\\.\\("     ;; whitelisted extension
             (apply 'concat
                    (mapcar
                     (lambda (extension) (concat (symbol-name extension) "\\|"))
                     f3-extension-whitelist)
                    )
             "$^\\)$"
             "\\)" ;;end or
             )
            file))
         list))
       (after-blacklist
        (delete-if
         (lambda (file)
           (string-match f3-blacklist-regexp file))
            after-whitelist)))
    after-blacklist))

(defun f3-switch-project ()
  "Switch current project dir from a subdir of the projects-dir"
  (interactive)
  (let* ((projects-hash
          (mapcar
           (lambda (fulldir)
             (cons (file-name-nondirectory fulldir) fulldir))
           (find-to-list f3-projects-dir "-type d -maxdepth 1")))
         (project-names
          (mapcar 'car projects-hash))
         (user-selection
          (ido-completing-read "Switch project:" project-names))
         (selection-pair
          (assoc user-selection projects-hash))
         (selected-project (cdr selection-pair)))
    (f3-load-project selected-project)))

(defun f3-load-project (dir)
  "Load (cache) a project directory"
  (interactive "DProject directory")
  (setq f3-current-project-dir dir)
  (setq f3-current-project-name (file-name-nondirectory dir))
  (setq f3-current-project-list
        (f3-filter
         (find-to-list dir)))
  (message (format "Loaded %d files from project \"%s\"" (length f3-current-project-list) f3-current-project-name)))

(defun f3-current-project ()
  "Load a file from the current cached project directory"
  (interactive)
  (if (boundp 'f3-current-project-list)
      (ido-find-file-from-list f3-current-project-list f3-current-project-dir)
    (message "No project selected")))


(defalias 'f3 'f3-current-project)

(defun ido-find-file-from-list (list &optional opt_prefix)
  "Utilize ido-mode to visit a file from a predifined list with an optional common prefix truncated"
  (let* ((prefix
         (or opt_prefix ""))
        (truncated-list
         (mapcar (lambda (full)
                   (substring full (length prefix)))
                 list))

        (selection (ido-completing-read "Open:" truncated-list))
        (file (concat prefix selection)))
    (find-file file)))

(defun find-to-list (dir &optional params)
  "run unix find with given arguments on a specific directory and return the results as a list"
  (split-string
   (with-temp-buffer
     (shell-command
      (concat f3-find-command " " dir " " params) t)
     (buffer-string))
   "\n"
   t))

(provide 'dancar-f3)
