Autoplace
For use with Matlab 5.2 or higher.

By: Douglas L. Harriman 
    Hewlett-Packard VCD
    doug_harriman@hp.com


Ever get irritated that every time you open a figure window,
it appears in the same place the last window appeared?  I got
tired of always moving windows around, so I wrote a few functions
to handle the placement of figure windows on the screen.

Autoplace automatically puts new figure windows in positions that
you define.  To define these positions do the following:

(1) Close all open windows.
(2) CD to the directory in which you want to store the figure
    position definition file.
(3) Open 1 window, and place it where you want it to open.
(4) Run 
     >> getpos
    This will store the definition for the figure position.
(5) Open and position another window.  Note that you can move 
    the first window to a different position.  Upon opening the
    second window, the first will be moved to a differnet position.
(6) Run 
     >> getpos
    To store the next figure position definition.

Repeat steps 5 & 6 until you have as many figures positioned on 
the screen as you like.

Note:
* You have to turn autoplace on for it to automatically position 
  your figure windows.  Do this with the following command:

    >> autoplace on

  I suggest putting this line in your startup.m file.


* getpos.m creates a file called figures.ini which is used by 
  figurecreatedelete.m, and stores the position definitions.
  You may have multiple figures.ini files, as long as they are
  in different directories.  Matlab should look in the current 
  directory for this file before looking on the search path.  This
  allows you to have different figure position definitions in 
  different directories.

* Autoplace works by overriding the default figure open and close
  functions.  If you are using other programs that use these funcitons
  you may have conflicts.  Turning autoplace off should resolve these
  conflicts.

* Autoplace only places user opened figures.  It does not attempt to place
  all windows that Matlab opens.  FigureCreateDelete.m assumes that figures 
  with the following properties are user figures:
     
     Property      Value
     --------      -----
     NumberTitle   On
     Name          ''
     Position      DefaultFigurePosition

  If you want to change this definition, do so in FigureCreateDelete.m


File list:
autoplace.m          Turns automatic figure placement on or off.
getpos.m             Takes the current figure positions as the placement definition.
figurecreatedelete.m Handles the automatic placement upon figure creation and deletion.