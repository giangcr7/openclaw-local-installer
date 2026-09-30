# OpenClaw Local Installer

Bộ cài OpenClaw native cho Windows, macOS và Linux. Chạy trực tiếp trên máy local qua UltraViewer; không cần Docker, Docker Desktop hoặc VPS.

## Cài nhanh

1. Tải `native-full-bundle.tar.gz` và lấy SHA256 trong `native-full-bundle.sha256` từ GitHub Release.
2. Chạy launcher tương ứng bằng quyền Administrator/root.
3. Nhập Bot Token và Provider API Key trực tiếp khi installer hỏi.

- Windows: `bootstrap-native.ps1`
- macOS/Linux: `bootstrap-native.sh`
- Prompt đầy đủ: `PROMPT-CÀI-ĐẶT.md`

Bundle gồm 192 skill sạch, OpenClaw pinned version, Telegram owner/approval, Full Exec policy và kiểm tra gateway. Không chứa token, API key, session, cookie hoặc dữ liệu khách.

Không đưa credential vào URL, GitHub, prompt hoặc log.
