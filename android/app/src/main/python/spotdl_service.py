import json
import re
import os
import threading
import traceback
import urllib.request

try:
    import yt_dlp  # pyre-ignore[21]: Installed by Chaquopy at build time
except ImportError:
    yt_dlp = None  # pyre-ignore[9]

try:
    from spotdl import Spotdl  # pyre-ignore[21]
    from spotdl.types.options import DownloaderOptions  # pyre-ignore[21]
except Exception:
    Spotdl = None  # pyre-ignore[9]
    DownloaderOptions = None  # pyre-ignore[9]

_download_thread = None
_cancel_flag = False
_event_sink = None


def validate_url(url):
    """Validate if the given URL is a valid Spotify link."""
    patterns = {
        'track': r'https?://open\.spotify\.com/track/[a-zA-Z0-9]+',
        'playlist': r'https?://open\.spotify\.com/playlist/[a-zA-Z0-9]+',
        'album': r'https?://open\.spotify\.com/album/[a-zA-Z0-9]+',
    }

    for url_type, pattern in patterns.items():
        if re.match(pattern, url):
            return json.dumps({
                'valid': True,
                'type': url_type,
                'url': url
            })

    return json.dumps({
        'valid': False,
        'type': None,
        'url': url,
        'message': 'Invalid Spotify URL'
    })


def _emit(status, progress, message, msg_type='info'):
    """Emit a JSON status line."""
    payload = json.dumps({
        'status': status,
        'progress': progress,
        'message': message,
        'type': msg_type
    })
    try:
        if _event_sink is not None:
            _event_sink.emit(payload)
            return
    except Exception:
        pass
    try:
        from com.example.spotdl_downloader import PythonEmitter
        PythonEmitter.emit(payload)
        return
    except Exception:
        print(payload, flush=True)


def set_event_sink(sink):
    """Set Kotlin event sink for streaming progress."""
    global _event_sink
    _event_sink = sink


def _extract_spotify_id(url):
    """Extract the Spotify track/playlist/album ID from a URL."""
    match = re.search(r'spotify\.com/(track|playlist|album)/([a-zA-Z0-9]+)', url)
    if match:
        return match.group(1), match.group(2)
    return None, None


def _fetch_spotify_oembed_title(url):
    """Fetch Spotify oEmbed data to build a better YouTube search query."""
    try:
        oembed_url = f"https://open.spotify.com/oembed?url={url}"
        with urllib.request.urlopen(oembed_url, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        title = data.get("title", "").strip()
        if title:
            return title
    except Exception:
        return None
    return None


def start_download(url, output_dir, quality='320', skip_existing=True,
                    embed_art=True, normalize=False):
    """
    Start downloading audio from a Spotify URL using yt-dlp.
    Converts Spotify URL to a YouTube search and downloads.
    Streams progress as JSON lines to stdout.
    """
    global _cancel_flag
    _cancel_flag = False

    # Validate URL first
    validation = json.loads(validate_url(url))
    if not validation['valid']:
        _emit('error', 0, 'Invalid Spotify URL', 'error')
        return

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    _emit('downloading', 0, 'Starting download...', 'info')

    try:
        if Spotdl is None or DownloaderOptions is None:
            _emit('error', 0, 'spotdl is not available. Check build config.', 'error')
            return

        _emit('downloading', 3, 'Preparing spotdl...', 'info')

        audio_quality = quality
        options = DownloaderOptions(
            output=output_dir,
            bitrate=audio_quality,
            save_file=None,
            overwrite=not skip_existing,
            print_errors=True,
            ffmpeg="ffmpeg",
            m3u=False,
            log_level="INFO",
            use_ytm_data=True,
            threads=1,
        )
        spotdl = Spotdl(options)

        _emit('downloading', 10, 'Fetching metadata...', 'info')
        songs = spotdl.search([url])
        if not songs:
            _emit('error', 0, 'No tracks found for URL.', 'error')
            return

        _emit('downloading', 20, f'Found {len(songs)} track(s).', 'info')

        for index, song in enumerate(songs, start=1):
            if _cancel_flag:
                raise Exception("Download cancelled by user")
            title = getattr(song, "name", "Unknown Track")
            artist = ", ".join(getattr(song, "artists", []) or [])
            _emit('downloading', 25, f'Downloading {index}/{len(songs)}: {title} - {artist}', 'info')
            spotdl.download(song)

        _emit('converting', 95, 'Finalizing files...', 'info')

        if not _cancel_flag:
            _emit('completed', 100, 'Download completed successfully!', 'success')

    except Exception as e:
        error_msg = str(e)
        if 'cancelled' in error_msg.lower():
            _emit('cancelled', 0, 'Download cancelled by user', 'warning')
        else:
            _emit('error', 0, f'Download failed: {error_msg}', 'error')
            debug_trace = os.getenv('SPOTDL_DEBUG', '').strip()
            if debug_trace == '1':
                _emit('error', 0, traceback.format_exc(), 'error')


def cancel_download():
    """Cancel the current download."""
    global _cancel_flag
    _cancel_flag = True

    return json.dumps({
        'status': 'cancelled',
        'progress': 0,
        'message': 'Download cancellation requested',
        'type': 'warning'
    })


def get_version():
    """Return yt-dlp version info."""
    try:
        return json.dumps({
            'status': 'success',
            'version': f"yt-dlp {yt_dlp.version.__version__}",  # pyre-ignore[16]
            'type': 'info'
        })
    except Exception as e:
        return json.dumps({
            'status': 'error',
            'message': str(e),
            'type': 'error'
        })
