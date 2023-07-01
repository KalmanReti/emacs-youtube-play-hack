# emacs-youtube-play-hack
Elisp file to play multiple youtube videos comprising a musical work in order and without ads

It implements m-x play-raff3-vln-sonata as an example of how to automatically
play a sequence of youtube videos under the control of emacs. If you have YouTube
premium, this is all you need to play the entire piece without ads.

If you DON'T have YouTube premium, you can use the embedded video site reached by inserting
a dash ('-') into the full video URL after the "t" in "youtube".  This site will play the
video in a full-screen windows, but also causes it to loop.  So this option requires shutting
down the browser after the video for a given movement has finished playing.  This embedded
variant is invoked with c-U m-x play-raff3-vln-sonata and currently only works if you are
1) on windows and 2) Microsoft Edge is your default browser.
