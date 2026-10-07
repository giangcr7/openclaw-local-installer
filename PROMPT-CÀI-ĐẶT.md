# Prompt cài OpenClaw V6 cho VPS thành viên và máy local

## Nguồn tải chính thức

GitHub repository chính thức hiện có release preview cũ. Release V6 chưa được
publish nên không được dùng link preview đó để tải bundle V6.

```text
Repository: https://github.com/giangcr7/openclaw-local-installer
Release V6 sau khi publish: <GITHUB_V6_RELEASE_URL>
Native bundle sau khi publish: <GITHUB_V6_NATIVE_BUNDLE_URL>
SHA256 sau khi publish: <GITHUB_V6_SHA256_URL>
Bootstrap Unix sau khi publish: <GITHUB_V6_BOOTSTRAP_UNIX_URL>
Bootstrap Windows sau khi publish: <GITHUB_V6_BOOTSTRAP_WINDOWS_URL>
```

Không đặt Telegram token, API key, mật khẩu SSH, cookie hoặc session vào URL,
GitHub, prompt công khai, file release hay log. Token/key phải nhập bằng secure
input trên đúng VPS hoặc máy khách.

## 1. Prompt cài VPS thành viên

Copy prompt dưới đây cho AI đang thao tác trên VPS thành viên:

```text
Cài OpenClaw V6 cho VPS thành viên bằng Docker Golden image, không sửa V5 và
không lấy dữ liệu/runtime/credential của member khác.

Thông tin thành viên:
- Tên user Linux: [TEN_USER]
- Mật khẩu SSH: nhập trực tiếp trên phiên SSH/console, không ghi vào chat hoặc file release
- Tên trợ lý: [TEN_TRO_LY]
- Đối tượng phục vụ: [DOI_TUONG_PHUC_VU]
- Cách xưng hô: [CACH_XUNG_HO]
- Phong cách trả lời: [PHONG_CACH]
- Telegram Bot Token: nhập secure trên VPS
- Telegram Owner IDs: [OWNER_ID_1,OWNER_ID_2,...]
- Telegram Group ID: [GROUP_ID hoặc để trống]
- 9Router API key: nhập secure trên VPS
- Model: [MODEL_ID]
- Base URL: [BASE_URL]

Nguồn V6:
- Repository: https://github.com/giangcr7/openclaw-local-installer
- Release V6: thay bằng các URL `<GITHUB_V6_...>` sau khi publish; không dùng `v0.1.2-preview`
- Template nội bộ dự phòng: /root/Apps/member_vps/template-releases/member-vps-v6-20261006

Yêu cầu thực hiện:
1. Chạy dry-run trước, sau đó mới cài thật bằng install.sh của V6.
2. Dùng profile basic-assistant-full; profile này đã gồm trợ lý cơ bản,
   Telegram, Office/OCR, audio/media, memory, scheduler/watchdog, web research,
   recovery và Zalo Personal.
3. Không cài module nâng cao nếu chưa được yêu cầu; chỉ gắn thêm bằng
   member-module khi member cần.
4. Lưu dữ liệu persistent riêng tại data/[TEN_USER], không dùng dữ liệu member khác.
5. Nhập token/API key vào secret store mode 600; không in giá trị thật ra log.
6. Cấu hình owner approval, owner IDs, group policy và Full Exec theo policy V6.
7. Chạy config validate, member-module validate, skills check và gateway status.
8. Với Zalo Personal: cài module trước, sau đó onboarding QR/pairing/owner access
   trên đúng VPS này; tuyệt đối không copy cookie/session từ member khác.
9. Với Telegram group: vào @BotFather, gửi /setprivacy, chọn đúng bot và chọn
   Disable để bot nhận tin không cần mention.
10. Không gửi tin nhắn thật khi kiểm tra nếu chưa có xác nhận.

Báo cáo cuối cùng: OpenClaw version, container, profile, module đã cài, owner IDs
đã cấu hình (chỉ hiện ID, không hiện token), gateway status, Zalo onboarding status,
đường dẫn data và các bước còn cần owner thực hiện.
```

Lệnh tham khảo trên VPS:

```bash
bash /root/Apps/member_vps/template-releases/member-vps-v6-20261006/install.sh /path/customer.json dry-run
bash /root/Apps/member_vps/template-releases/member-vps-v6-20261006/install.sh /path/customer.json
docker exec user-[TEN_USER] member-module list
docker exec user-[TEN_USER] member-module validate
```

## 2. Prompt cài máy local native

Copy prompt dưới đây khi cài qua UltraViewer/AnyDesk trên máy khách. Máy local
chạy OpenClaw native, không cài Docker hoặc Docker Desktop.

```text
Cài OpenClaw V6 native trực tiếp trên máy local hiện tại qua UltraViewer/AnyDesk.

Không cài Docker, Docker Desktop hoặc container.
Tự nhận diện Windows, macOS hoặc Linux.
Tải bộ cài từ GitHub V6, kiểm tra SHA256 trước khi chạy và không dùng release cũ.

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

Link tải:
- Repository: https://github.com/giangcr7/openclaw-local-installer
- Release V6: thay bằng các URL `<GITHUB_V6_...>` sau khi publish; không dùng `v0.1.2-preview`
- Native bundle: `<GITHUB_V6_NATIVE_BUNDLE_URL>`
- SHA256: `<GITHUB_V6_SHA256_URL>`

Yêu cầu thực hiện:
1. Tải bundle, tải file SHA256 và xác minh checksum trước khi giải nén.
2. Cài Node.js, Python và FFmpeg nếu hệ điều hành còn thiếu.
3. Cài profile basic-assistant-full và native module manager; sau cài phải
   dùng được Telegram/OpenClaw ngay sau khi gateway chạy.
4. Cấu hình tên trợ lý, đối tượng phục vụ, xưng hô, phong cách, Telegram owner,
   owner approval và Full Exec theo policy V6.
5. Lưu token/API key bằng secret file phù hợp hệ điều hành; không ghi vào prompt,
   URL, GitHub hoặc log.
6. Linux/macOS có thể cài thêm module Zalo Personal mặc định. Windows native
   không được cam kết Zalo Personal nếu catalog không đánh dấu hỗ trợ; báo rõ
   cho người cài thay vì cài sai transport.
7. Sau khi cài, chạy config validate, skills check và gateway status.
8. Vào @BotFather -> /setprivacy -> chọn bot -> Disable nếu bot dùng trong group.
9. Không gửi tin nhắn thật khi kiểm tra nếu chưa được xác nhận.
10. Báo lại hệ điều hành, OpenClaw version, profile, module đã cài, gateway
    status và đường dẫn runtime.
```

Linux/macOS chạy Terminal với quyền root:

```bash
curl -fL -o bootstrap-native.sh <GITHUB_V6_BOOTSTRAP_UNIX_URL>
chmod +x bootstrap-native.sh
sudo -H ./bootstrap-native.sh --bundle-url "<GITHUB_V6_NATIVE_BUNDLE_URL>" --sha256 "<V6_SHA256_VALUE>" --name "[TEN_USER_LOCAL]" --owner-ids "[OWNER_ID_1,OWNER_ID_2]" --base-url "[BASE_URL]" --model "[MODEL_ID]" --profile basic-assistant-full --module zalo-personal
```

Windows PowerShell Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
Invoke-WebRequest -Uri "<GITHUB_V6_BOOTSTRAP_WINDOWS_URL>" -OutFile bootstrap-native.ps1
.\bootstrap-native.ps1 -BundleUrl "<GITHUB_V6_NATIVE_BUNDLE_URL>" -Sha256 "<V6_SHA256_VALUE>" -Name "[TEN_USER_LOCAL]" -OwnerIds "[OWNER_ID_1,OWNER_ID_2]" -BaseUrl "[BASE_URL]" -Model "[MODEL_ID]" -Profile basic-assistant-full
```

## 3. Gắn module về sau

Máy local cũ không cần chuyển sang Docker. Giải nén đúng native bundle V6,
cài module manager một lần rồi cài module cần thiết:

```bash
bash native/install-module-manager-unix.sh
member-module-native validate --module zalo-personal
member-module-native install --module zalo-personal
member-module-native list
```

```powershell
.\native\install-module-manager-windows.ps1
& "$env:USERPROFILE\.openclaw\module-manager.ps1" -Command validate -Module zalo-personal
& "$env:USERPROFILE\.openclaw\module-manager.ps1" -Command install -Module zalo-personal
```

Docker member dùng `docker exec user-[TEN_USER] member-module install --module
[MODULE_ID]`. Sau khi gắn module có credential riêng, phải onboarding/pairing
trên chính máy đó; cài module không tự đăng nhập Zalo/Facebook/Google Drive.
