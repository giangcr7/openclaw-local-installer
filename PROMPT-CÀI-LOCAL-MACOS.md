# Prompt cài OpenClaw V6 native trên macOS

Copy toàn bộ prompt sau khi thao tác qua AnyDesk/Screen Sharing trên máy macOS.

```text
Cài OpenClaw V6 native trực tiếp trên máy macOS hiện tại.

Không cài Docker, Docker Desktop hoặc container.
Mở Terminal và chạy bằng sudo -H khi installer yêu cầu quyền root.
Không dùng lệnh Windows và không SSH vào VPS.

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
- Bootstrap: https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/bootstrap-native.sh
- Native bundle: https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/native-full-bundle.tar.gz
- SHA256 file: https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/native-full-bundle.sha256

Yêu cầu:
1. Tải bundle và SHA256, xác minh checksum trước khi giải nén.
2. Chạy bootstrap-native.sh bằng sudo -H với profile basic-assistant-full và
   module zalo-personal nếu khách sử dụng Zalo Personal.
3. Installer tự chuẩn bị Homebrew, Node.js, Python và FFmpeg nếu thiếu; tạo
   launchd/local gateway theo cấu hình V6.
4. Cài native module manager và các module core.
5. Cấu hình tên trợ lý, đối tượng phục vụ, xưng hô, phong cách, Telegram owner,
   owner approval và Full Exec theo policy V6.
6. Nhập Bot Token/API key bằng secure input; không ghi vào prompt, URL, GitHub,
   file release hoặc log.
7. Nếu cài Zalo, owner phải quét QR, pairing và xác nhận owner access trên đúng
   máy Mac; không copy cookie/session từ máy khác.
8. Chạy config validate, skills check và gateway status.
9. Nếu dùng group Telegram, vào @BotFather -> /setprivacy -> chọn bot -> Disable.
10. Không gửi tin nhắn thật khi kiểm tra nếu chưa có xác nhận.

Báo cáo macOS version, OpenClaw version, profile, module đã cài, gateway status
và đường dẫn runtime. Không hiển thị Bot Token/API key.
```

Lệnh tải và chạy nhanh trong Terminal:

```bash
curl -fL -o bootstrap-native.sh https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/bootstrap-native.sh
chmod +x bootstrap-native.sh
sudo -H ./bootstrap-native.sh --bundle-url "https://github.com/giangcr7/openclaw-local-installer/releases/download/v0.2.0-v6-20261006/native-full-bundle.tar.gz" --sha256 "96fa98ccf65a72b04ff58944d73cef7d39f1671a36bc4e259e9d377da6433b8a" --name "[TEN_USER_LOCAL]" --owner-ids "[OWNER_ID_1,OWNER_ID_2]" --base-url "[BASE_URL]" --model "[MODEL_ID]" --profile basic-assistant-full --module zalo-personal
```

## Gắn module sau này

```bash
bash native/install-module-manager-unix.sh
member-module-native validate --module [MODULE_ID]
member-module-native install --module [MODULE_ID]
```

