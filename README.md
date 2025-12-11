# cli-music-player

A lightweight Bash script to stream YouTube music directly in the terminal using mpv and yt-dlp.

This repository provides a small shell script that lets you search for and stream music from YouTube (and other yt-dlp-supported sites) directly in your terminal using mpv as the player and yt-dlp for fetching media. The script is intended to be simple, minimal, and easy to integrate into your shell workflow.

## Features

- Stream audio directly from YouTube (no long downloads)
- Works with direct URLs or search queries
- Uses mpv for playback and yt-dlp to fetch streaming URLs
- Minimal dependencies and simple configuration via environment variables
- Easy to integrate with fzf or other terminal tooling for interactive selection

## Requirements

- Bash (POSIX-compatible shell)
- mpv (media player)
- yt-dlp (stream URL extractor and YouTube search tool)
- jq (JSON processor for parsing search results)
- curl or wget (optional, for some helper commands)
- (Optional) fzf for interactive search/selection

Install on Debian/Ubuntu:
```bash
sudo apt update
sudo apt install -y mpv jq curl  # or wget
python3 -m pip install --user -U yt-dlp
```

Install on macOS (Homebrew):
```bash
brew install mpv yt-dlp fzf
```

On Arch:
```bash
sudo pacman -S mpv yt-dlp fzf
```

Make sure yt-dlp is up to date to avoid site breakages:
```bash
python3 -m pip install --user -U yt-dlp
# or
yt-dlp -U
```

## Installation

Clone the repository and make the script executable:
```bash
git clone https://github.com/anurag-sn/cli-music-player.git
cd cli-music-player
chmod +x cli-music-player.sh
```

(Optional) Install globally:
```bash
sudo ln -s "$(pwd)/cli-music-player.sh" /usr/local/bin/cli-music-player
# or copy the script to ~/bin/
```

## Basic usage

There are two common usage patterns: using the script to handle search or providing a direct URL.

Search and play music by query (displays multiple results for selection):
```bash
./cli-music-player.sh "Billie Eilish bury a friend"
```

Or simply run without arguments for an interactive search prompt:
```bash
./cli-music-player.sh
```

If you installed the script to your PATH:
```bash
cli-music-player "lofi hip hop"
```

You can run it with a search query as an argument or without arguments for an interactive prompt.

## Screenshots

Below are screenshots showing the script in action. The images are included in the repository under `assets/screenshots/`.

1) Search prompt

![Search prompt](assets/screenshots/screenshot-1.png)

2) Search results list

![Search results list](assets/screenshots/screenshot-2.png)

3) Player running (mpv)

![Player running](assets/screenshots/screenshot-3.png)

## Under the hood (how it works)

Typical steps the script performs:

1. Accept a search query (as an argument or via interactive prompt).
2. Use yt-dlp with YouTube search extractor to find top 5 matching videos.
3. Display the results with titles and uploaders for user selection.
4. Allow user to select one or more songs (or all) to play.
5. Pass the selected YouTube URLs to mpv for streaming.
6. mpv streams the audio (with `--no-video`), providing low-latency playback without downloading the full file.

Common standalone commands used to stream without the script:
- Use mpv directly with a YouTube URL (mpv will call yt-dlp internally if compiled that way):
  ```bash
  mpv --no-video "https://www.youtube.com/watch?v=VIDEO_ID"
  ```
- Get direct media URL with yt-dlp and play with mpv:
  ```bash
  mpv --no-video "$(yt-dlp -f bestaudio -g 'https://www.youtube.com/watch?v=VIDEO_ID')"
  ```
- Pipe best audio to mpv:
  ```bash
  yt-dlp -f bestaudio -o - 'https://www.youtube.com/watch?v=VIDEO_ID' | mpv --no-video -
  ```

## Configuration

The script can be made configurable using environment variables (set them in your shell rc file, e.g., `~/.bashrc` or `~/.profile`):

- PLAYER — command to run the player (default: mpv)
  ```bash
  export PLAYER="mpv --no-video"
  ```
- YTDLP_OPTS — extra options passed to yt-dlp
  ```bash
  export YTDLP_OPTS="--no-playlist --extract-audio"
  ```
- MPV_OPTS — extra options passed to mpv
  ```bash
  export MPV_OPTS="--volume=60 --terminal --no-video"
  ```

Example:
```bash
export PLAYER="mpv --no-video"
export YTDLP_OPTS="--no-playlist"
export MPV_OPTS="--volume=50"
```

## Integrations and tips

- Interactive search with fzf:
  You can pipe a list of search results into fzf, choose one, and then call the script with the selection.
  Example (conceptual):
  ```bash
  yt-dlp "ytsearch10:lofi hip hop" --get-title --get-id | nl -w2 -s': ' | fzf -n1 | awk '{print $2}' | xargs -I{} cli-music-player "https://www.youtube.com/watch?v={}"
  ```
  (Adapt the pipeline to the script's name and available options.)

- Use mpv input commands for advanced playback control. For example, you can pass JSON IPC or use `mpv --input-ipc-server=/tmp/mpvsocket` to control playback from other scripts.

- Use cookie files if you encounter age-restricted content:
  ```bash
  yt-dlp --cookies /path/to/cookies.txt ...
  ```

## Troubleshooting

- "mpv: command not found" — install mpv.
- "yt-dlp: command not found" — install yt-dlp (pip or package manager).
- Playback fails or yt-dlp errors — update yt-dlp: `python3 -m pip install --user -U yt-dlp` or `yt-dlp -U`.
- Region-restricted or age-restricted video — try using cookies exported from your browser and pass `--cookies` to yt-dlp.
- If audio is choppy or connection is unstable, try a lower-quality audio format (e.g., `-f 'bestaudio[abr<=128]'`).

## Security and privacy

- The script streams content from third-party sites; be mindful of privacy and legal considerations for your country.
- Using cookies from your browser may expose account-related data. Keep cookie files secure and delete them after use.

## Contributing

Contributions are welcome. Here are common ways to contribute:

- Open an issue for bugs or feature requests.
- Submit a pull request with a fix or enhancement.
- Improve documentation or add examples and platform-specific instructions.

When opening issues or PRs, include the output of `bash -x ./cli-music-player.sh ...` (or your shell's verbose trace) if reporting a bug, plus versions of mpv and yt-dlp.

## Example quickstart

1. Ensure dependencies:
   ```bash
   mpv --version
   yt-dlp --version
   ```

2. Make the script executable and run:
   ```bash
   chmod +x cli-music-player.sh
   ./cli-music-player.sh "lofi hip hop radio"
   ```

3. Or play a direct link:
   ```bash
   ./cli-music-player.sh "https://www.youtube.com/watch?v=jfKfPfyJRdk"
   ```

## License

This project is provided under the MIT License. See the LICENSE file for details.

## Acknowledgements

- mpv — a powerful media player used for playback
- yt-dlp — a downloader and URL resolver for many platforms, including YouTube
- All contributors and maintainers of the underlying tools and libraries