import subprocess
import json
import re
import os
import signal
import sys

# Global process reference for cancellation
_current_process = None


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


def start_download(url, output_dir, quality='320', skip_existing=True,
                    embed_art=True, normalize=False):
    """
    Start downloading a Spotify track/playlist using spotdl.
    Streams progress as JSON lines to stdout.
    """
    global _current_process

    # Validate URL first
    validation = json.loads(validate_url(url))
    if not validation['valid']:
        print(json.dumps({
            'status': 'error',
            'progress': 0,
            'message': 'Invalid Spotify URL',
            'type': 'error'
        }))
        return

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Build spotdl command
    cmd = [
        sys.executable, '-m', 'spotdl',
        'download', url,
        '--output', output_dir,
        '--format', 'mp3',
        '--bitrate', f'{quality}k',
    ]

    if not skip_existing:
        cmd.append('--overwrite')
        cmd.append('force')

    if not embed_art:
        cmd.append('--no-embed-metadata')

    if normalize:
        cmd.append('--ffmpeg-args')
        cmd.append('-af loudnorm')

    # Emit start status
    print(json.dumps({
        'status': 'downloading',
        'progress': 0,
        'message': 'Starting download...',
        'type': 'info'
    }), flush=True)

    try:
        _current_process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        progress_pattern = re.compile(r'(\d+)%')
        song_pattern = re.compile(r'Found\s+\d+\s+songs?', re.IGNORECASE)
        download_pattern = re.compile(r'Downloading', re.IGNORECASE)
        convert_pattern = re.compile(r'Converting|Processing', re.IGNORECASE)
        skip_pattern = re.compile(r'Skipping.*already exists', re.IGNORECASE)
        error_pattern = re.compile(r'error|failed|exception', re.IGNORECASE)

        for line in _current_process.stdout:
            line = line.strip()
            if not line:
                continue

            # Determine message type and status
            msg_type = 'info'
            status = 'downloading'
            progress = -1

            # Parse progress percentage
            match = progress_pattern.search(line)
            if match:
                progress = int(match.group(1))

            # Detect phases
            if song_pattern.search(line):
                status = 'downloading'
                msg_type = 'info'
                print(json.dumps({
                    'status': status,
                    'progress': 5,
                    'message': 'Fetching metadata...',
                    'detail': line,
                    'type': msg_type
                }), flush=True)
                continue

            if download_pattern.search(line):
                status = 'downloading'
                msg_type = 'info'

            if convert_pattern.search(line):
                status = 'converting'
                msg_type = 'info'

            if skip_pattern.search(line):
                msg_type = 'warning'
                print(json.dumps({
                    'status': 'downloading',
                    'progress': progress if progress >= 0 else 0,
                    'message': line,
                    'type': 'warning'
                }), flush=True)
                continue

            if error_pattern.search(line):
                msg_type = 'error'

            output = {
                'status': status,
                'progress': progress if progress >= 0 else 0,
                'message': line,
                'type': msg_type
            }
            print(json.dumps(output), flush=True)

        _current_process.wait()

        if _current_process.returncode == 0:
            print(json.dumps({
                'status': 'completed',
                'progress': 100,
                'message': 'Download completed successfully!',
                'type': 'success'
            }), flush=True)
        else:
            print(json.dumps({
                'status': 'error',
                'progress': 0,
                'message': f'Download failed with exit code {_current_process.returncode}',
                'type': 'error'
            }), flush=True)

    except Exception as e:
        print(json.dumps({
            'status': 'error',
            'progress': 0,
            'message': str(e),
            'type': 'error'
        }), flush=True)
    finally:
        _current_process = None


def cancel_download():
    """Cancel the current download process."""
    global _current_process
    if _current_process is not None:
        try:
            _current_process.terminate()
            _current_process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            _current_process.kill()
        finally:
            _current_process = None

        return json.dumps({
            'status': 'cancelled',
            'progress': 0,
            'message': 'Download cancelled by user',
            'type': 'warning'
        })

    return json.dumps({
        'status': 'error',
        'progress': 0,
        'message': 'No active download to cancel',
        'type': 'error'
    })


def get_version():
    """Return spotdl version info."""
    try:
        result = subprocess.run(
            [sys.executable, '-m', 'spotdl', '--version'],
            capture_output=True, text=True, timeout=10
        )
        return json.dumps({
            'status': 'success',
            'version': result.stdout.strip(),
            'type': 'info'
        })
    except Exception as e:
        return json.dumps({
            'status': 'error',
            'message': str(e),
            'type': 'error'
        })
