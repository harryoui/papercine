# papercine

# Instructions:
1. Set movie_dir and working_dir variables within script

2. Ensure all dependencies are installed:
- homebrew (https://brew.sh/)
- ffmpeg (homebrew)
- wallpaper (homebrew)

3. Configure crontab, eg:
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/opt/homebrew/bin
*/5 * * * * /Users/harryallen/scripts/wallpaper/wallpaper.sh > /Users/harryallen/scripts/wallpaper/error.txt 2>&1

# Functionality
1. Script will select a movie within movie_dir unless a movie is given
./wallpaper.sh 'Spider-Man Into the Spider-Verse (2018).mkv'

2. Script is configured to only update the wallpaper if MacOS is charging via AC
