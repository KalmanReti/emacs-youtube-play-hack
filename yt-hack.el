;; Emacs hack to play a musical work with multiple movements as
;; separate YouTube videos in order. (You could then capture it
;; via audacity or OBS as a complete audio/video, if desired.)
;; This currently only works on windows.  I bought a cheap ($100)
;; refurb minipc to run things like this on.

;; This file implements m-x play-raff3-vln-sonata which uses the
;; predefined list of videos and their play times (see defvar
;; below).

;; There are two modes: normal (which you should use if you have
;; YouTube premium and hence never get ads) and embedded, which
;; you should use if you don't have premium.  Furthermore, embedded
;; requres that Microsoft Edge be your default browser, i.e. the
;; one that m-x browse-url pops up.  You get embedded mode by
;; prefixing m-x play-raff3-vln-sonata with c-U.

;; Because emacs uses sleeps to wait for video to end, it is
;; busy for the duration; it changes the frame title to reflect
;; that fact. (I generally have lots of emacsen each with an
;; appropriate frame title for what I am doing in that emacs.)

;; If you have YouTube premium, you don't need the embedded site
;; to avoid ads. In this case, each movement will get a new tab
;; in your default browser and will play once through until the
;; end.  The tabs will still be there, so you can replay at your
;; whim/leisure.

;; If you don't have premium, type c-U before command tells the
;; function to use the embedded site (by adding "-" after "t" in
;; "youtube" in the full URL).  The embedded site fullscreens and
;; loops the video, so you have to kill the browser it is running
;; in when the movement ends.

;; I don't use Edge, but I leave it as default so I can know
;; if something else launched a browser on me, so killing the
;; browser that is running the looping embedded video is equivalent
;; to killing all msedge processes.  This emacs will be busy for
;; the duration of the playback (due to use of sleep-for).

(require'cl) ;; for loop

(defun py (code &optional use-embedded-site description)
  "open YouTube video for 'code' in default browser (in embedded site if arg)"
  (message (format "%s Playing %s on %s site"
		   (current-time-string)
		   (or description code)
		   (if use-embedded-site "embedded" "normal")))
  (browse-url (format "https://yout%sube.com/watch?v=%s"
		      (if use-embedded-site "-" "") code)))

;; This is the test video sequence; the Raff 3rd violin is a
;; four-movement work, each movement as separate video, with play time
;; and description taken directly from the YouTube description.
;; I looked into detecting that audio was playing, but didn't
;; find anything simple, so I just wait for the elapsed time
;; of the video, and kill the browser afterward if using the
;; embedded mode (because otherwise it will repeat).

;; You can find (at the time of this writing) these four videos
;; by searching for "daskalakis raff opus 128" in YouTube.

;; Performance by Ariadne Daskalakis, violin and Roglit Ishay, piano
(defvar raff3rdvlnsonata
  '(("09:01" "UHk7RIlUZOo" "Raff: Vln Son #3 Op128: I Allegro")
    ("04:11" "pLZ69w7fy7k" "Raff: Vln Son #3 Op128: II Allegro assai")
    ("07:00" "Y8FxmkYUiZI" "Raff: Vln Son #3 Op128: III Andante quasi larghetto")
    ("05:29" "A-WuZTBcWYI" "Raff: Vln Son #3 Op128: IV Allegro vivace")))

;; utility function used in function just below
(defun shell-command-to-string (command)
    (shell-command command)
    (with-current-buffer "*Shell Command Output*"
      (buffer-substring-no-properties (point-min) (point-max))))

;; My default browser is Microsoft edge, which I never use for anything
;; "real", so I can kill all msedge processes without impacting my 'work'.
;; The embedded site will make the video fullscreen and repeating, so
;; after it is over, I use this to kill the browser in which a movement
;; is playing.
(defun kill-all-msedge-exe ()
  (loop with start = 0
	with new-procs = (shell-command-to-string "tasklist")
	for  msedge-pos = (search "msedge.exe" new-procs :start2 start)
	while msedge-pos
	do (setq start (+ msedge-pos 10))
	for rest-of-line = (substring
			    new-procs
			    (+ msedge-pos 10)
			    (position 10 new-procs :start (+ msedge-pos 10)))
	do (shell-command-to-string
	    (format "taskkill /pid %d"
		    (car (read-from-string rest-of-line))))))

;; Here's the m-x command
(defun play-raff3-vln-sonata (&optional use-embedded-site)
  "Play the Joachim Raff 3rd violin sonata Op. 128, with Ariadne Daskalakis, vln and Roglit Ishay, pno."
  (interactive "P")
  (unwind-protect
      (progn
	(set-frame-name "busy playing Joachim Raff Violin Sonata #3 Op. 128, Ariadne Daskalakis, vln and Roglit Ishay, pno.")
	(loop for (time code desc) in raff3rdvlnsonata
	      for i from 0
	      for rest = (not (eql i 3))
	      do (when (and (zerop i) use-embedded-site)
		   ;; kill msedge if there is one before starting when embedded
		   (kill-all-msedge-exe))
	      ;; play video
	      (py code use-embedded-site desc)
	      (let* ((mmss (split-string time ":"))
		     (seconds-to-sleep
		      (+ (cl-parse-integer (second mmss))
			 (* 60 (cl-parse-integer (first mmss))))))
		(when (> (length mmss) 2)
		  (debug "got more than mm:ss"))
		(when (or use-embedded-site rest)
		  ;; for embedded, always sleep because we have to kill
		  ;; for non-embedded, don't need to sleep for last video
		  (sleep-for seconds-to-sleep)
		  (when use-embedded-site
		    (kill-all-msedge-exe))))))
    (message (format "%s done playing Raff 3rd violin sonata"
		     (current-time-string)))
    (set-frame-name nil)))

