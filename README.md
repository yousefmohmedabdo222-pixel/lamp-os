# 🪔 Lamp OS - A Beautiful Linux Experience

> *"The impossible is just a perspective, and age is not a barrier to serious technical innovation."*

## 🎯 الرؤية (Vision)

Lamp OS هو نظام تشغيل ثوري يكسر الفرضيات التقليدية:
- ❌ **الأنظمة القوية لا يجب أن تكون معقدة**
- ❌ **الأنظمة السهلة لا يجب أن تكون ثقيلة**

✨ **Lamp OS** يجمع بين:
- 🚀 **قوة Linux**: نواة موثوقة ومستقرة
- 🎨 **جمال Windows 7**: واجهة حديثة بتأثيرات بصرية رائعة
- ⚡ **سرعة فائقة**: استهلاك موارد منخفض
- 🔐 **أمان عالي**: استخدام Rust وأفضل الممارسات
- 👥 **سهولة الاستخدام**: لا حاجة للـ Terminal في الاستخدام اليومي

## 🎯 الهدف

إنشاء نظام تشغيل يكون الخيار الأول لـ:
- 👴 أصحاب الأجهزة القديمة الذين يريدون سرعة
- 💻 مستخدمي الأجهزة الحديثة الذين يريدون الجمال
- 🔐 جميع من يريدون الخصوصية والأمان
- 👶 الجميع بدون تعقيدات Linux أو ثقل Windows

## 💾 الخصائص الرئيسية

| الخاصية | التفاصيل |
|---------|----------|
| **الحجم** | < 500MB (كامل النظام) |
| **السرعة** | تمهيد < 5 ثوان |
| **الذاكرة** | < 100MB عند الراحة |
| **الأداء** | > 60 FPS |
| **التوافقية** | يعمل على أجهزة قديمة وحديثة |
| **المصدر** | 100% مفتوح المصدر |

## 🏗️ البنية التقنية

```
User Applications (C++)
        ↓
GUI Framework
        ↓
System Libraries (C, C++, Rust)
        ↓
Linux Kernel (6.6 - Customized)
        ↓
Hardware
```

### لغات البرمجة المستخدمة:
- **C**: التعامل المباشر مع طبقات النظام
- **C++**: الواجهات الرسومية والتطبيقات
- **Rust**: أدوات النظام والأمان الفائق

## 📋 المتطلبات

### نظام التشغيل:
- Ubuntu 20.04+ أو Debian 11+
- CPU: أي (يدعم x86_64, aarch64/arm64, arm, riscv، powerpc، mips، loongarch)
- RAM: 4GB (على الأقل للتطوير)
- مساحة تخزين: 20GB

> قم بتعيين المتغير `TARGET_ARCH` و `CROSS_COMPILE` عند البناء لاستهداف معمارية مختلفة.

### البرامج المطلوبة:
```bash
sudo apt install -y \
    build-essential gcc g++ make cmake \
    git wget curl \
    libssl-dev libncurses-dev \
    flex bison \
    dosfstools grub-pc-bin xorriso \
    qemu-system-x86 qemu-system-aarch64 qemu-system-arm qemu-system-riscv \
    # (اختياري) cross compilers: gcc-aarch64-linux-gnu, gcc-riscv64-unknown-elf, gcc-powerpc64le-linux-gnu
```

## 🚀 البدء السريع

### 1. استنساخ المشروع:
```bash
git clone https://github.com/yousefmohmedabdo222-pixel/lamp-os.git
cd lamp-os
```

### 2. إعداد البيئة:
```bash
chmod +x *.sh
mkdir -p {kernel,gui,initrd,iso/{boot/grub,live},src}
```

### 3. بناء النظام:
```bash
# بناء النواة
./build_quick.sh

# أو البناء الكامل
./build_complete.sh
```

### 4. الاختبار:
```bash
# اختبار مع QEMU
qemu-system-x86_64 -cdrom lamp-os-working.iso -m 512 -smp 2 -enable-kvm
```

## 📚 التوثيق

| الملف | الوصف |
|------|-------|
| [VISION.md](VISION.md) | رؤية المشروع الشاملة والفلسفة |
| [ROADMAP.md](ROADMAP.md) | خطة التطوير التفصيلية |
| [ARCHITECTURE.md](ARCHITECTURE.md) | البنية التقنية العميقة |
| [GETTING_STARTED.md](GETTING_STARTED.md) | دليل البدء خطوة بخطوة |

## 📂 هيكل المشروع

```
lamp-os/
├─ kernel/              # مصادر Linux Kernel
├─ gui/                 # الواجهة الرسومية (C++)
├─ initrd/              # نظام الملفات الأساسي
├─ src/                 # أدوات النظام (Rust, C)
├─ iso/                 # ملفات ISO للتمهيد
├─ build_*.sh          # نصوص البناء المختلفة
├─ VISION.md           # رؤية المشروع
├─ ROADMAP.md          # خطة التطوير
├─ ARCHITECTURE.md     # البنية التقنية
└─ GETTING_STARTED.md  # دليل البدء
```

## 🛣️ خطة التطوير

### المرحلة 1: البنية الأساسية (جارية ⏳)
- [x] توثيق الرؤية
- [x] إعداد البنية الأساسية
- [ ] نواة Linux مخصصة
- [ ] نظام Initrd

### المرحلة 2: الواجهة الرسومية (القادم)
- [ ] محرك الرسومات
- [ ] نظام إدارة النوافذ
- [ ] مكونات UI الأساسية

### المرحلة 3: التطبيقات (المستقبل)
- [ ] مدير الملفات
- [ ] محرر النصوص
- [ ] مراقب النظام

### المرحلة 4: التحسينات (النهاية)
- [ ] تحسينات الأداء
- [ ] اختبار شامل
- [ ] الإصدار الأول (Alpha)

## 🧑‍💻 المساهمة

نرحب بمساهماتك! يرجى اتباع الخطوات التالية:

1. **Fork** المشروع
2. **Clone** نسختك
3. **Create** branch جديد (`git checkout -b feature/amazing-feature`)
4. **Commit** تغييراتك (`git commit -m 'Add some amazing feature'`)
5. **Push** إلى branch (`git push origin feature/amazing-feature`)
6. **Open** Pull Request

### معايير المساهمة:
- ✅ كود نظيف وموثق
- ✅ اختبارات شاملة
- ✅ رسائل commit واضحة
- ✅ احترام القيم الأساسية للمشروع

## 📖 المراجع والموارد

- [Linux Kernel Documentation](https://www.kernel.org/doc/)
- [BusyBox Documentation](https://busybox.net/)
- [QEMU Documentation](https://wiki.qemu.org/)
- [C++ Graphics Programming](https://en.cppreference.com/)
- [Rust Language](https://www.rust-lang.org/)

## 📞 التواصل والدعم

- 📧 البريد الإلكتروني: (سيتم تحديثه)
- 🐛 الإبلاغ عن الأخطاء: [Issues](https://github.com/yousefmohmedabdo222-pixel/lamp-os/issues)
- 💬 النقاشات: [Discussions](https://github.com/yousefmohmedabdo222-pixel/lamp-os/discussions)

## 📜 الترخيص

هذا المشروع مرخص تحت [GPL v3 License](LICENSE)

---

## 🎬 الخطوات التالية الفورية

```bash
# اقرأ الوثائق
cat VISION.md        # الرؤية الكاملة
cat ROADMAP.md       # خطة العمل
cat ARCHITECTURE.md  # البنية التقنية

# ابدأ التطوير
./build_quick.sh     # بناء سريع
qemu-system-x86_64 -cdrom lamp-os-working.iso -m 512
```

---

## 💡 الفلسفة

> "هذا المشروع ليس مجرد كود، بل هو رحلتي لإعادة تعريف علاقة المستخدم العادي بنظام لينكس."

**المبادئ الأساسية:**
1. 🎯 **البساطة أولاً**: كل ميزة تضيف قيمة حقيقية
2. ⚡ **الأداء ثانياً**: لا نتهاون مع السرعة
3. 🔐 **الأمان دائماً**: الحماية الكاملة للمستخدم
4. 👥 **المستخدم في المركز**: نسأل "هل هذا يساعد المستخدم؟"

---

<div align="center">

### 🪔 Lamp OS: Light in the World of Complex Systems

**The impossible is just a perspective.**

</div>
