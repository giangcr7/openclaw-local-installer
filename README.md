# Member VPS Golden Template

Golden Template độc lập cho cài OpenClaw member mới. Bản này không chứa cấu hình, token, session, lịch sử, database hay dữ liệu của bất kỳ member nào.

## Thành phần mặc định

- Image `member-vps-golden:20260930`, dựa trên `vps-user-env:latest`.
- OpenClaw, Node, FFmpeg và Supervisor từ base image.
- Telegram/OpenClaw được cấu hình riêng cho từng khách.
- Module `basic-assistant` được nạp khi container khởi động.
- API key lưu trong file mode `600` và chỉ được export vào tiến trình gateway; không ghi giá trị thật vào `openclaw.json`.
- Container dùng `--restart unless-stopped`, nên không cần mở Docker Desktop thủ công sau khi máy khởi động nếu Docker Desktop đã bật auto-start.

## Cài member mới

### Native Windows (không Docker)

Đây là lựa chọn tối ưu khi cài qua UltraViewer trên máy khách. Chạy PowerShell bằng **Run as Administrator**; script cài Node.js nếu thiếu, cài cố định OpenClaw `2026.9.4`, tạo Windows daemon/service, lưu cấu hình trong `%USERPROFILE%\.openclaw` và không gọi Docker Desktop.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install-native-windows.ps1 -Name member01 -OwnerIds '123456789,987654321' `
  -GroupId '-1001234567890' -BaseUrl 'https://provider.example/v1' -Model 'model-id' -DryRun
```

Bỏ `-DryRun` để cài thật. Script hỏi Bot Token/API key bằng ô nhập bảo mật và không in chúng ra màn hình.

### Cài bằng một link

Sau khi upload `native-full-bundle.tar.gz` lên GitHub Release/CDN, khách không cần nhận file thủ công. Gửi `bootstrap-native.ps1` hoặc lệnh bootstrap kèm URL archive và SHA256 của đúng phiên bản. Bootstrap tải, kiểm tra checksum, giải nén tạm rồi mới chạy installer; không đặt secret vào URL.

Bootstrap dùng chung bundle cho cả ba hệ điều hành:

- Windows: `bootstrap-native.ps1` → Windows daemon.
- macOS: `bootstrap-native.sh` → launchd/local gateway, runtime `/var/root/.openclaw`.
- Linux: `bootstrap-native.sh` → systemd/local gateway, runtime `/root/.openclaw`.

Trên macOS/Linux phải chạy bằng `root` hoặc `sudo -H`; trên Windows phải chạy PowerShell Administrator. Mỗi launcher tự cài dependency nền tảng tương ứng, đồng bộ 192 skill, áp dụng owner/approval/Full Exec, validate và kiểm tra skill.

Bộ native đầy đủ gồm `native-full-bundle.tar.gz`. Khi gửi cho khách, giải nén cùng thư mục với script; bộ này chứa 192 skill đã làm sạch. Installer đồng bộ skill một lần, áp dụng owner policy/approval, cấu hình Full Exec và chạy `openclaw skills check` trước khi restart gateway.

Native Windows là bộ cài cho máy khách không có Docker. Script tự chuẩn bị Node.js, Python 3.12 và FFmpeg (nếu winget có sẵn), giữ đủ owner allowlist, group allowlist và Full Exec `gateway/full` (OpenClaw mới biểu diễn quyền tương đương `security=full`, `ask=off` bằng `mode=full`); gateway vẫn chỉ bind loopback. Golden Docker vẫn giữ cho VPS/phát triển; hai môi trường không dùng chung runtime hoặc credential.

### Windows/Docker Desktop

Dùng `install-member-local.ps1`. Image Golden đã chứa module; script chỉ import image một lần, bơm settings riêng và khởi động container. Không giải nén archive member cũ.

```powershell
.\install-member-local.ps1 -Name member01 -TelegramToken $tg -ProviderApiKey $key `
  -BaseUrl 'https://provider.example/v1' -Model 'model-id' `
  -OwnerIds '123456789,987654321' -GroupId '-1001234567890'
```

Chạy thử trước bằng cách thêm `-DryRun`.

1. Copy `settings.example.json` thành một file riêng bên ngoài release, ví dụ `customer.json`.
2. Điền `member`, Telegram token, owner IDs, provider base URL/API key/model.
3. Chạy dry-run:

```bash
bash install.sh /path/customer.json dry-run
```

4. Cài thật:

```bash
bash install.sh /path/customer.json
```

Không đưa file settings thật vào Git, archive, Docker image hoặc chat log.

## Thêm module cho các lần cài sau

Module chỉ được promote khi đã làm sạch secret, session và dữ liệu khách:

```bash
bash docker/promote-module.sh \
  --container user-MEMBER \
  --id ten-module \
  --source /root/Apps/ten-module
```

Sau đó build lại Golden:

```bash
bash build-golden.sh 20260930
```

Bản build mới sẽ nạp module trong `modules/enabled.txt` cho member cài sau. Khách cũ không tự đổi vì dữ liệu của họ nằm trong volume riêng; muốn nâng cấp phải dùng quy trình upgrade có kiểm soát.

## Module format

```text
modules/ten-module/
├── module.json
├── skills/       # copy vào /root/.openclaw/workspace/skills/
├── apps/         # copy vào /root/Apps/
└── supervisor/   # tùy chọn, copy supervisor .conf
```

`module.json` bắt buộc có `id` và `version`. Không đặt token, API key, cookie, session, credential, database runtime hoặc dữ liệu khách trong module.

## Zalo

Zalo Personal không nằm trong Golden cơ bản. Cài sau bằng module/quy trình riêng trên đúng container member, không copy session từ member khác và không thay đổi Telegram đang chạy.
