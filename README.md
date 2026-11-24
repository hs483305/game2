# 小小夢魔・藍洞大冒險

給小學生玩的繁體中文生活理財教育冒險。主遊戲是純 HTML、CSS、JavaScript，無需建置工具或後端，可直接部署在 GitHub Pages 或 Netlify。

## 本機預覽

直接以瀏覽器開啟 `index.html`，或在此資料夾執行 `python -m http.server 8000`，再開啟 `http://localhost:8000`。進度儲存在瀏覽器的 localStorage。

## 遊戲內容

- 第一關「海底小市集」：分辨需要與想要、練習先存再花，以及安排短期目標。
- 第二關「珊瑚投資站」：認識分散風險、投資不保證獲利，以及和可信任的大人討論。
- 每關 3 個情境選擇題，答對至少 2 題取得鑰匙。回答後顯示說明；關卡結束顯示分數、最高分及學習成果。
- 關卡解鎖與分數會存在目前瀏覽器；尚未加入跨裝置同步。

## GitHub Pages

將此資料夾內容推送到 GitHub，於 Repository 的 **Settings → Pages → Deploy from a branch** 選擇部署分支與根目錄即可。

## Netlify

將 GitHub Repository 連至 Netlify，Build command 留空，Publish directory 設為 `.`。

## Godot 與 Blender

`godot/` 包含可在 Godot 4.7 開啟的原生遊戲專案。`blender/` 包含場景產生腳本；執行 `blender -b --python blender/create_scene.py` 會產生原生 `.blend` 場景與可重用的 `assets/little_diver.glb` 低多邊形角色模型。瀏覽器版不需要 Godot Web 執行環境或外部遊戲引擎。

美術以深海探索、明亮海底生態和微型冒險的原創視覺語彙設計；僅將使用者提供的遊戲頁面作為氛圍和探索題材參考，不包含其遊戲素材。
