;;; nix-search.el -- run nix commands in Emacs -*- lexical-binding: t -*-

;; Author: Matthew Bauer <mjbauer95@gmail.com>
;; Homepage: https://github.com/NixOS/nix-mode
;; Keywords: nix

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;;; Code:

(require 'nix)
(require 'json)

;;;###autoload
(defun nix-search (&optional search nix-file)
  "Run nix search.
SEARCH a search term to use.
NIX-FILE a Nix expression to search in."
  (interactive)
  (unless search (setq search ""))
  (unless nix-file (setq nix-file "<nixpkgs>"))
  (let ((stdout (generate-new-buffer "nix search"))
	result)
    (call-process nix-executable nil (list stdout nil) nil
		  "search" "--json" "-f" nix-file search)
    (with-current-buffer stdout
      (when (eq (buffer-size) 0)
	(error "Error: nix search %s failed to produce any output" search))
      (goto-char (point-min))
      (setq result (json-read)))
    (kill-buffer stdout)
    (when (called-interactively-p 'any)
      (let ((display (generate-new-buffer "*nix search*")))
	(with-current-buffer display
	  (dolist (entry result)
	    (widget-insert
	     (format "name: %s\nversion: %s\ndescription: %s\n\n"
		     (alist-get 'pkgName (cdr entry))
		     (alist-get 'version (cdr entry))
		     (alist-get 'description (cdr entry)))))
	  )
	(display-buffer display 'display-buffer-pop-up-window)))
    result))

(provide 'nix-search)
;;; nix-search.el ends here
