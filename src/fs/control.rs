use crate::action::Action;
use std::fs::File;
use std::io::{Read, Seek, SeekFrom};
use std::path::{Path, PathBuf};
use std::time::Duration;
use tokio::sync::mpsc;

/// How often the control file is checked for new lines.
const POLL_INTERVAL: Duration = Duration::from_millis(200);

/// Watch a control file and send [`Action::OpenRequested`] for every line
/// appended to it after startup.
///
/// Other processes (such as the herdr plugin) ask a running instance to open
/// a file by appending its path plus a newline. Polling the file length keeps
/// this independent of filesystem event quirks, and lines that were already
/// in the file when the app started are ignored.
///
/// The thread ends when the app's action channel is closed.
pub fn spawn_control_watcher(path: PathBuf, tx: mpsc::UnboundedSender<Action>) {
    std::thread::spawn(move || {
        let mut offset = file_len(&path);
        let mut partial = String::new();
        loop {
            std::thread::sleep(POLL_INTERVAL);
            if tx.is_closed() {
                return;
            }
            let len = file_len(&path);
            if len < offset {
                // Truncated or replaced: start over from the beginning.
                offset = 0;
                partial.clear();
            }
            if len == offset {
                continue;
            }
            let Some(chunk) = read_from(&path, offset) else {
                continue;
            };
            offset += chunk.len() as u64;
            partial.push_str(&String::from_utf8_lossy(&chunk));
            for request in take_complete_lines(&mut partial) {
                if tx.send(Action::OpenRequested(request)).is_err() {
                    return;
                }
            }
        }
    });
}

fn file_len(path: &Path) -> u64 {
    std::fs::metadata(path).map_or(0, |m| m.len())
}

fn read_from(path: &Path, offset: u64) -> Option<Vec<u8>> {
    let mut file = File::open(path).ok()?;
    file.seek(SeekFrom::Start(offset)).ok()?;
    let mut buf = Vec::new();
    file.read_to_end(&mut buf).ok()?;
    Some(buf)
}

/// Remove every complete (newline-terminated) line from `buffer` and return
/// the non-empty ones as paths. An unterminated tail stays in `buffer`.
fn take_complete_lines(buffer: &mut String) -> Vec<PathBuf> {
    let Some(end) = buffer.rfind('\n') else {
        return Vec::new();
    };
    let complete: String = buffer.drain(..=end).collect();
    complete
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(PathBuf::from)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn complete_lines_are_taken_and_tail_is_kept() {
        let mut buffer = "/a.md\n\n/b c.md\n/partial".to_string();
        let lines = take_complete_lines(&mut buffer);
        assert_eq!(
            lines,
            vec![PathBuf::from("/a.md"), PathBuf::from("/b c.md")]
        );
        assert_eq!(buffer, "/partial");
    }

    #[test]
    fn no_newline_yields_nothing() {
        let mut buffer = "/a.md".to_string();
        assert!(take_complete_lines(&mut buffer).is_empty());
        assert_eq!(buffer, "/a.md");
    }

    #[tokio::test]
    async fn appended_lines_become_open_requests() {
        let dir = tempfile::tempdir().expect("tempdir");
        let control = dir.path().join("control");
        std::fs::write(&control, "/old.md\n").expect("write");
        let (tx, mut rx) = mpsc::unbounded_channel();
        spawn_control_watcher(control.clone(), tx);

        // Give the watcher time to record the initial length.
        tokio::time::sleep(POLL_INTERVAL * 2).await;
        let mut file = std::fs::OpenOptions::new()
            .append(true)
            .open(&control)
            .expect("open");
        std::io::Write::write_all(&mut file, b"/new.md\n").expect("append");

        let action = tokio::time::timeout(Duration::from_secs(3), rx.recv())
            .await
            .expect("no open request within 3s")
            .expect("channel closed");
        match action {
            Action::OpenRequested(path) => assert_eq!(path, PathBuf::from("/new.md")),
            _ => panic!("unexpected action"),
        }
    }
}
