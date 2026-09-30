# Prompt cài OpenClaw local

Dùng prompt này khi cài qua UltraViewer trên chính máy khách:

```text
Cài OpenClaw native trên chính máy local hiện tại qua UltraViewer.

Không cài Docker hoặc Docker Desktop.
Không SSH vào VPS.
Không dùng container.
Tự nhận diện Windows, macOS hoặc Linux.
Tải bundle từ link GitHub chính thức và kiểm tra SHA256 trước khi chạy.

Thông tin khách hàng:
- Member name: [MEMBER_NAME]
- Telegram Bot Token: nhập trực tiếp trên máy khách
- Telegram Owner IDs: [OWNER_ID_1, OWNER_ID_2]
- Telegram Group ID: [GROUP_ID hoặc bỏ trống]
- Provider API Key: nhập trực tiếp trên máy khách
- Base URL: [BASE_URL]
- Model: [MODEL_ID]

Yêu cầu:
- Cài OpenClaw đúng phiên bản trong bundle.
- Cài Node.js, Python và FFmpeg nếu thiếu.
- Đồng bộ toàn bộ skill sạch trong bundle.
- Cấu hình Telegram owner, group allowlist và owner approval.
- Bật Full Exec cho agent main theo policy của bundle.
- Tạo service/daemon chạy nền theo đúng hệ điều hành.
- Chạy config validate, skills check và gateway status.
- Không gửi tin nhắn thật để test nếu chưa được xác nhận.
- Không in hoặc lưu Bot Token/API key vào prompt, URL, GitHub hoặc log.
- Báo hệ điều hành, OpenClaw version, gateway status và đường dẫn runtime.
```

## Dùng link bootstrap

Thay `BUNDLE_URL` và `BUNDLE_SHA256` bằng giá trị trong GitHub Release tương ứng. Không đặt secret vào URL.

Windows chạy PowerShell Administrator:

```powershell
.\bootstrap-native.ps1 -BundleUrl "BUNDLE_URL" -Sha256 "BUNDLE_SHA256" -Name "member01" -OwnerIds "OWNER_ID_1,OWNER_ID_2" -BaseUrl "BASE_URL" -Model "MODEL_ID"
```

macOS/Linux chạy Terminal với quyền root:

```bash
sudo -H bash bootstrap-native.sh --bundle-url "BUNDLE_URL" --sha256 "BUNDLE_SHA256" --name "member01" --owner-ids "OWNER_ID_1,OWNER_ID_2" --base-url "BASE_URL" --model "MODEL_ID"
```

Bot Token và API key sẽ được installer hỏi trực tiếp bằng secure input.
