# OCR_aoe2
## Why
Getting more information from Age of Empires 2 to better analyse games

## Steps

### (0 Using a Game Mod to make numbers)
Unfortunatly, I couldnt do it with the standard ressource panel. The numbers are very small and the background can distract the ocr by a lot. Thats why I created a small mod which increases the font size and replaces distracting parts of the ressource panel with black background.

### 1 Taking the video and enhance it
I use ffmpeg to film the ressource panel and timer.  The video needs some enhancement to make it better readable for the tesseract. Thats why I gray scale it, then negate it to have black letters and double the size.
Last I take picutres for every second of the video (not every in game second).

### 2 Using R to read the screenshots
I use the libraries magick for image processing and tesseract to read the data. See the code. I increase the accuracy by decreasing the canvas to each datafield.
With microbenchmark I tested the speed of the process and could increase it by editing most images with ffmpeg instead of R. Now 624 pictures take around 60sec to read.

## Result
Now I have a pretty nice table with a lot of information about the game.
