# Prompt cài OpenClaw V6 native trên Windows

Copy toàn bộ prompt sau khi thao tác qua UltraViewer/AnyDesk trên máy Windows.

```text
Cài OpenClaw V6 native trực tiếp trên máy Windows hiện tại qua UltraViewer/AnyDesk.

Không cài Docker, Docker Desktop hoặc container.
Mở PowerShell bằng Run as Administrator.
Không dùng lệnh Linux/macOS và không SSH vào VPS.

Thông tin khách hàng:
- Tên user local: [TEN_USER_LOCAL]
- Tên trợ lý: [TEN_TRO_LY]
- Đối tượng phục vụ: [DOI_TUONG_PHUC_VU]
- Cách xưng hô: [CACH_XUNG_HO]
- Phong cách trả lời: [PHONG_CACH]
- Telegram Bot Token: nhập trực tiếp bằng secure input trên máy khách
- Telegram Owner IDs: [OWNER_ID_1,OWNER_ID_2,...]
- Telegram Group ID: [GROUP_ID hoặc để trống]
- 9Router API key: nhập trực tiếp bằng secure input trên máy khách
- Model: [MODEL_ID]
- Base URL: [BASE_URL]

Nguồn tải V6:
- Release: https://github.com/giangcr7/openclaw-local-installer/releases/tag/v0.2.0-v6-20261006
- Bootstrap: https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/bootstrap-native.ps1
- Native bundle: https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/native-full-bundle.tar.gz
- SHA256 file: https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/native-full-bundle.sha256

Yêu cầu:
1. Tải bundle và SHA256, xác minh checksum trước khi giải nén.
2. Chạy install-native-windows.ps1 với profile basic-assistant-full.
3. Cài Node.js, Python và FFmpeg nếu thiếu; tạo Windows daemon/service.
4. Cài native module manager và các module core.
5. Cấu hình tên trợ lý, đối tượng phục vụ, xưng hô, phong cách, Telegram owner,
   owner approval và Full Exec theo policy V6.
6. Nhập Bot Token/API key bằng secure input; không ghi vào prompt, URL, GitHub,
   file release hoặc log.
7. Không tự cài hoặc cam kết Zalo Personal trên Windows native nếu catalog chưa
   đánh dấu Windows tương thích; báo rõ giới hạn cho người dùng.
8. Chạy config validate, skills check và gateway status.
9. Nếu dùng group Telegram, vào @BotFather -> /setprivacy -> chọn bot -> Disable.
10. Không gửi tin nhắn thật khi kiểm tra nếu chưa có xác nhận.

Báo cáo hệ điều hành, OpenClaw version, profile, module đã cài, gateway status
và đường dẫn runtime. Không hiển thị Bot Token/API key.
```

Lệnh tải và chạy nhanh trong PowerShell Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
Invoke-WebRequest -Uri "https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/bootstrap-native.ps1" -OutFile bootstrap-native.ps1
.\bootstrap-native.ps1 -BundleUrl "https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/native-full-bundle.tar.gz" -Sha256 "96fa98ccf65a72b04ff58944d73cef7d39f1671a36bc4e259e9d377da6433b8a" -Name "[TEN_USER_LOCAL]" -OwnerIds "[OWNER_ID_1,OWNER_ID_2]" -BaseUrl "[BASE_URL]" -Model "[MODEL_ID]" -Profile basic-assistant-full
```

## Gắn module sau này

```powershell
.\native\install-module-manager-windows.ps1
& "$env:USERPROFILE\.openclaw\module-manager.ps1" -Command validate -Module [MODULE_ID]
& "$env:USERPROFILE\.openclaw\module-manager.ps1" -Command install -Module [MODULE_ID]
```

