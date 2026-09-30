# OpenClaw Local Installer

Bộ cài OpenClaw native cho Windows, macOS và Linux. Chạy trực tiếp trên máy local qua UltraViewer; không cần Docker, Docker Desktop hoặc VPS.

## Trạng thái bản phát hành

Bản `v0.1.0-preview` là bản thử nghiệm. Đã kiểm tra cấu hình OpenClaw và cú pháp shell trên Linux; chưa kiểm thử cài end-to-end trên Windows sạch, macOS và Linux sạch. Không coi việc có 192 skill là mọi tích hợp đã hoạt động: từng module vẫn cần dependency, tài khoản và kiểm tra tương thích riêng. Không dùng trực tiếp trên máy khách production trước khi thử trên máy test. Quyền Full Exec cho phép lệnh thực thi với quyền tài khoản chạy gateway.

Link duy nhất để gửi người cài: https://github.com/giangcr7/openclaw-local-installer

Prompt: [PROMPT-CÀI-ĐẶT.md](PROMPT-CÀI-ĐẶT.md)

Bundle và checksum: https://github.com/giangcr7/openclaw-local-installer/releases/tag/v0.1.0-preview

## Cài nhanh

1. Tải `native-full-bundle.tar.gz` và lấy SHA256 trong `native-full-bundle.sha256` từ GitHub Release.
2. Chạy launcher tương ứng bằng quyền Administrator/root.
3. Nhập Bot Token và Provider API Key trực tiếp khi installer hỏi.

- Windows: `bootstrap-native.ps1`
- macOS/Linux: `bootstrap-native.sh`
- Prompt đầy đủ: `PROMPT-CÀI-ĐẶT.md`

Bundle gồm 192 skill sạch, OpenClaw pinned version, Telegram owner/approval, Full Exec policy và kiểm tra gateway. Không chứa token, API key, session, cookie hoặc dữ liệu khách.

Không đưa credential vào URL, GitHub, prompt hoặc log.
