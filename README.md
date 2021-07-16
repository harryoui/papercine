# papercine

# Instructions:
1. Set movie_dir and working_dir variables within script

2. Ensure all dependencies are installed:
- [Homebrew](https://brew.sh/) 
  
  `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- [FFmpeg](https://formulae.brew.sh/formula/ffmpeg) 
  
  `brew install ffmpeg`
- [Wallpaper](https://formulae.brew.sh/formula/wallpaper)
  
  `brew install wallpaper`

3. Configure crontab for update frequency, and ensure homebrew is within path, for example:
```
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/opt/homebrew/bin
*/5 * * * * /Users/harryallen/scripts/wallpaper/wallpaper.sh > /Users/harryallen/scripts/wallpaper/error.txt 2>&1
 ```
# Functionality
1. Script will select a movie within movie_dir unless a video file is specified
./wallpaper.sh 'Spider-Man Into the Spider-Verse (2018).mkv'

2. Script is configured to only update the wallpaper if MacOS is charging via AC, although this can be easily modified at the beginning of the script
