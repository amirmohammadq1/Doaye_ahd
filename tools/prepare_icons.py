"""logo.webp را به PNG تبدیل می‌کند تا flutter_native_splash و flutter_launcher_icons آن را بپذیرند.
خروجی: build_tmp/logo.png  (فقط هنگام ساخت لازم است و در گیت ذخیره نمی‌شود)"""
import os
import sys

from PIL import Image

SRC = 'assets/logo.webp'
OUT = 'build_tmp/logo.png'

if not os.path.exists(SRC):
    sys.exit('ERROR: %s پیدا نشد؛ فایل لوگو را در assets/logo.webp بگذارید.' % SRC)
os.makedirs('build_tmp', exist_ok=True)
img = Image.open(SRC).convert('RGBA')
img.save(OUT)
print('OK: %s (%dx%d) -> %s' % (SRC, img.width, img.height, OUT))
