# hyprsummon

> 🇬🇧 [English](README.md)

Herhangi bir uygulamayı Hyprland üzerinde tek tuşla açılıp kapanan bir katman (scratchpad) olarak kullan.
Bir tuş gösterir. Aynı tuş gizler. Alt-tab yok, workspace geçişi yok.

<!-- demo gif buraya -->

## Ne işe yarar?

Hyprland'da [special workspace](https://wiki.hyprland.org/Configuring/Workspace-Rules/#special-workspace) var — açılıp kapanan gizli katman workspace'ler.
Chromium ile [herhangi bir siteyi uygulama olarak kurabilirsiniz](https://support.google.com/chrome/answer/9658361) — tarayıcı arayüzü olmayan bağımsız bir pencere.

**hyprsummon** bu ikisini birleştirir. Kurulu PWA'larınızı otomatik bulur ve her birine tek tuşla erişim sağlar:

```
Super+Y    → YouTube kayarak açılır
Super+Y    → YouTube kaybolur
Super+B    → Binance açılır
Super+Esc  → Açık olan ne varsa kapat
```

Chromium, Brave, Edge ve tüm Chromium tabanlı tarayıcılarla çalışır. PWA olmayan uygulamalarla da çalışır — Steam, Spotify, terminal, penceresi olan her şey.

## Kurulum

**Arch Linux (AUR):**
```bash
paru -S hyprsummon-git
# veya: yay -S hyprsummon-git
```

**Manuel:**
```bash
git clone https://github.com/yeggis/hyprsummon.git
cd hyprsummon
sudo make install
```

Ya da sadece kopyalayın:
```bash
cp hyprsummon ~/.local/bin/
chmod +x ~/.local/bin/hyprsummon
```

**Bağımlılıklar:** Hyprland (≥ 0.40), jq, bash (≥ 4.0)

```bash
# Arch
sudo pacman -S jq

# Fedora
sudo dnf install jq

# Ubuntu/Debian
sudo apt install jq
```

## İki kullanım şekli

### Wizard modu — `pick`

En kolay yol. İstediğiniz uygulamayı açın, sonra:

```bash
hyprsummon pick
```

3 saniyelik geri sayım sırasında hedef pencereye tıklayın. Ardından isim, kısayol ve uygulama adımlarını tek seferde halledin.

```
$ hyprsummon pick
Focus the window you want to add.
  Capturing in 3... 2... 1...
  Caught: Spotify — Liked Songs

Name [spotify]:
Keybind (e.g. Super, Z): Super, M
>>> 'spotify' added.
>>> spotify → Super, M

Apply now? [Y/n]:
>>> Rules → ~/.config/hypr/hyprsummon/rules.conf
>>> Binds → ~/.config/hypr/hyprsummon/binds.conf
>>> Hyprland reloaded ✓
```

Bitti. `Super+M`'ye basın — Spotify kayarak açılır.

### Komut modu

Toplu kurulum veya script'ler için. `scan` tüm PWA'ları tek seferde bulur:

```bash
hyprsummon scan                        # kurulu tüm PWA'ları bul
hyprsummon bind youtube 'Super, Y'     # kısayol ata
hyprsummon bind chatgpt 'Super+Shift, 1'
hyprsummon apply                       # config yaz, Hyprland'ı yenile
```

`apply` otomatik olarak üç şey yapar:
1. `~/.config/hypr/hyprsummon/rules.conf` dosyasına windowrule'ları yazar
2. `~/.config/hypr/hyprsummon/binds.conf` dosyasına kısayolları yazar
3. `hyprland.conf`'a `source` satırlarını ekler (sadece ilk çalıştırmada) ve Hyprland'ı yeniler

Hyprland config dosya yapınız ne olursa olsun çalışır.

## PWA olmayan uygulamalar

İki yol:

**Wizard ile** — uygulamayı açın ve `hyprsummon pick` çalıştırın. Pencere sınıfını otomatik algılar.

**Manuel:**

```bash
hyprsummon add steam steam "steam -silent" 5
hyprsummon add terminal kitty kitty 1
hyprsummon bind steam 'Super+Shift, G'
hyprsummon apply
```

Format: `hyprsummon add <isim> <pencere_sınıfı> [başlatma_komutu] [bekleme_süresi]`

## Komutlar

| Komut | Ne yapar |
|---|---|
| `hyprsummon <uygulama>` | Uygulamayı aç/kapat |
| `hyprsummon dismiss` | Açık olan special workspace'i kapat |
| `hyprsummon pick` | İnteraktif wizard — odakla, isimle, kısayol ata, uygula |
| `hyprsummon scan` | Tüm Chromium PWA'larını bul |
| `hyprsummon list` | Kayıtlı uygulamaları ve kısayolları göster |
| `hyprsummon status` | Çalışan/durmuş durumları göster |
| `hyprsummon bind <app> '<tuş>'` | Kısayol ata |
| `hyprsummon apply` | Config yaz + Hyprland'ı yenile |
| `hyprsummon add <ad> <class> [cmd] [wait]` | Manuel uygulama ekle |
| `hyprsummon remove <ad>` | Uygulamayı kaldır |

## Dismiss tuşu

`hyprsummon dismiss` o an görünen special workspace'i kapatır. `apply` bunu varsayılan olarak `Super+Escape`'e bağlar.

Değiştirmek için:

```bash
echo 'dismiss_key=Super+Shift, Escape' > ~/.config/hyprsummon/settings.conf
hyprsummon apply
```

## Nasıl çalışır?

`hyprsummon youtube` çalıştırdığınızda:

```
┌──────────────────────────────────┐
│  Pencere special ws'de mi?       │
└──────────┬───────────────────────┘
      evet │              hayır
           │    ┌────────────────────┐
  toggle   │    │  Pencere bir yerde │
  (gizle/  │    │  çalışıyor mu?     │
   göster) │    └──────┬─────────────┘
           │      evet │        hayır
           │           │
           │   special │    başlat +
           │   ws'ye   │    pencere
           │   taşı    │    oluşana
           │   + göster│    kadar bekle
```

- **Atomik kilitleme** — `mkdir` tabanlı kilit, hızlı tuş basışlarından kaynaklanan çift tetiklemeyi önler
- **Tek sorgu** — pencere durumu `hyprctl clients -j` ile tek seferde kontrol edilir
- **Başlatma kilidi** — yavaş başlayan uygulamalarda çift pencere açılmasını önler

## Config dosyaları

**Uygulama kaydı** — `~/.config/hyprsummon/apps.conf`:
```
youtube|chrome-agimnkijcaahngcdmfeangaknmldooml-Default|gtk-launch youtube.desktop|1|Super, Y
steam|steam|steam -silent|5|Super+Shift, G
```

Sınıf adları Chromium'un iç app-id'sini içerir ve her tarayıcı kurulumuna özgüdür. `scan` bu yüzden var — `.desktop` dosyalarınızı okuyarak sisteminize ait doğru ID'leri bulur.

**Ayarlar** — `~/.config/hyprsummon/settings.conf` (opsiyonel):
```
dismiss_key=Super, Escape
```

**Üretilen Hyprland config'leri** — `~/.config/hypr/hyprsummon/`:
```
rules.conf    # uygulamaları special workspace'lere sabitleyen windowrule'lar
binds.conf    # hyprsummon'ı çağıran kısayollar
```

## SSS

**Neden tarayıcı sekmeleri kullanmıyoruz?**
PWA'ların adres çubuğu, sekmesi, tarayıcı arayüzü yoktur. Special workspace'lerle birleşince anında erişilebilen katman uygulamalarına dönüşürler — dropdown terminal gibi, ama her şey için.

**Tarayıcıyı yeniden kurduktan sonra pencere sınıfı değişti.**
`hyprsummon scan` tekrar çalıştırın. App-id yeniden kurulumda değişir.

**Kayma animasyonunu özelleştirebilir miyim?**
Evet, Hyprland config'inizde:
```ini
animation = specialWorkspace, 1, 3, default, slidevert
```

**Firefox desteği?**
Firefox yerel olarak PWA desteklemez. `hyprsummon pick` veya `hyprsummon add` ile doğru pencere sınıfını kullanın.

## Lisans

MIT
