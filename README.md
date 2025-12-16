# 🎧 Music App

Ứng dụng nghe nhạc ngoại tuyến được xây dựng bằng Flutter, tập trung vào trải nghiệm người dùng tối ưu, hiệu suất cao và quản lý thư viện nhạc cục bộ một cách dễ dàng.

## 🖼️ Giao diện Ứng dụng

Dưới đây là một số hình ảnh về giao diện chính của ứng dụng.
---
<div align="center">

<img src="screenshot\anh1.jpg" width="100"/>
<img src="screenshot\anh2.jpg" width="100"/>
<img src="screenshot\anh3.jpg" width="100"/>

</div>

---
## 🛠️ Cấu trúc và Công nghệ

Dự án này tuân theo kiến trúc Clean Architecture đơn giản và sử dụng các công nghệ sau:

* **Ngôn ngữ:** Dart
* **Framework:** Flutter
* **Quản lý Trạng thái:** `provider`
* **Phát nhạc:** `just_audio`
* **Truy vấn nhạc:** `on_audio_query`
* **Lưu trữ cục bộ:** `shared_preferences`
### Các bước thực hiện

1.  **Clone repository:**
    ```bash
    git clone (https://github.com/phuongprox/flutter_music_app_nguyennamphuong)
    cd flutter_music_app_nguyennamphuong
    ```

2.  **Tải các dependency:**
    ```bash
    flutter pub get
    ```

3.  **Yêu cầu quyền truy cập Bộ nhớ:**
    Do ứng dụng truy cập tệp nhạc cục bộ, bạn cần đảm bảo cấp quyền `READ_EXTERNAL_STORAGE` trong tệp `AndroidManifest.xml` (Android) hoặc `Info.plist` (iOS).

4.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```
