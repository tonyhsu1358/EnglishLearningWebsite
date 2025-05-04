<%@ Page Language="C#" AutoEventWireup="true" CodeFile="VocabularyGame.aspx.cs" Inherits="VocabularyGame" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Vocabulary Game</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" />
    <style>
        /* ===== 全局樣式 ===== */
        body {
            background: url('images/grassland1.svg') no-repeat center center fixed; /* 設定背景圖片不重複、置中且固定 */
            background-size: cover; /* 背景圖填滿整個畫面 */
        }

        /* 狀態欄 */
        #navbar {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 10px;
            background: rgba(0, 0, 0, 0);
            color: white;
            position: absolute;
            top: 10px;
            right: 10px;
            border-radius: 10px;
            padding: 5px 15px;
        }

        .resource {
            margin: 0 10px;
            font-weight: bold;
            font-size: 18px;
            background: rgba(255, 255, 255, 0.6); /* 半透明白底 */
            padding: 4px 10px;
            border-radius: 8px;
            color: #000; /* 黑字看得清楚 */
            display: flex;
            align-items: center;
            gap: 5px;
        }


        /* 🎯 森林選擇按鈕容器 (可自由移動) */
        .forest-select-container {
            position: absolute; /* 讓容器能夠自由放置在頁面上的特定位置 */
            top: 300px; /* 距離頁面頂部 300px */
            left: 20px; /* 距離頁面左側 20px */
        }

        /* 🎯 森林選擇按鈕 (美化) */
        #forest-select {
            width: 120px; /* 設定按鈕的寬度 */
            height: 120px; /* 設定按鈕的高度 */
            cursor: pointer; /* 讓滑鼠懸停時變成手指 (點擊手勢) */
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; /* 平滑動畫 */
        }

            /* 🟢 滑鼠懸停時讓按鈕有 "上浮" 效果 */
            #forest-select:hover {
                transform: translateY(-5px); /* 往上移動 5px */
                transform: translateY(-5px) scale(1.1); /* 🪄 加上 scale 放大效果 */
            }

        /* ===== 魔法祭壇 (主框架，可自由調整位置) ===== */
        .altar-container {
            position: absolute; /* ✅ 位置不變 */
            top: 290px;
            left: 200px;
            width: 1300px;
            height: 400px;
            background: radial-gradient(circle at top left, #fdf6e3, #f0dab1); /* ✨ 柔和奶油色漸層背景 */
            border: 3px solid #a07c4c; /* 🪄 更有魔法感的邊框 */
            border-radius: 20px;
            box-shadow: 0 0 20px rgba(160, 124, 76, 0.4); /* 🪄 柔和外陰影 */
            padding: 10px;
            display: grid;
            place-items: center;
        }

        /* 🎯 祭壇內的按鈕排列 (讓按鈕填滿空間) */
        .altar-grid {
            display: grid;
            grid-template-columns: repeat(20, 1fr); /* 固定 20 欄 */
            grid-template-rows: repeat(5, 1fr); /* 固定 5 列（總共 100 顆） */
            gap: 5px;
            width: 100%;
            height: 100%;
            padding: 10px;
            box-sizing: border-box;
        }

        .altar-button {
            transition: filter 0.3s ease-in-out, transform 0.3s ease-in-out;
            font-size: 20px; /* ← 加上這行即可變大，依需求可調整大小 */
            font-weight: bold;
        }

            .altar-button:hover {
                filter: brightness(1.3);
                transform: scale(1.03);
            }

            /* 🪨 初始狀態（未學習）*/
            .altar-button.locked {
                width: 100%;
                height: 100%;
                background: #a9a9a9; /* 石頭灰色 */
                color: #fff;
                border: 2px solid #555;
                box-shadow: inset 0 0 5px #333;
                border-radius: 10px;
            }

            /* 🌱 學習中狀態 */
            .altar-button.learning {
                width: 100%;
                height: 100%;
                background: linear-gradient(135deg, #b3d59c, #76b852); /* 淺綠 + 森林綠 */
                color: #fff;
                border: 2px solid #4e944f;
                box-shadow: 0 0 5px #76b852;
                animation: pulse 2s infinite;
                border-radius: 10px;
            }

            /* 🍂 乾枯狀態（提醒複習） */
            .altar-button.withered {
                width: 100%;
                height: 100%;
                background: linear-gradient(135deg, #c79857, #7e5f33); /* 褐色調 */
                color: #fffbe0;
                border: 2px dashed #5a3e1b;
                box-shadow: 0 0 5px rgba(255, 204, 0, 0.5);
                border-radius: 10px;
            }

            /* ✨ 完全狀態（完成） */
            .altar-button.completed {
                width: 100%;
                height: 100%;
                background: linear-gradient(135deg, #ffd700, #ffb400); /* 金黃色調 */
                color: #fff;
                border: 2px solid #c98c00;
                box-shadow: 0 0 10px rgba(255, 223, 0, 0.8);
                font-weight: bold;
                border-radius: 10px;
            }

        /* 💓 呼吸動畫 */
        @keyframes pulse {
            0% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.05);
            }

            100% {
                transform: scale(1);
            }
        }

        /* ===== 告示牌 & 資訊按鈕 (綁定在一起，可自由調整位置) ===== */
        .billboard-container {
            position: absolute; /* 讓你可以自由移動 */
            top: -130px;
            left: 5px;
            display: flex;
            align-items: center;
        }

        #billboard {
            width: 140px;
            height: auto;
        }

        .forest-label {
            position: absolute;
            top: 40px;
            left: 11px;
            font-size: 30px;
            font-weight: bold;
            color: black;
            z-index: 10; /* 提高層級，確保文字在最上層 */
        }

        .info-button {
            position: absolute;
            right: 10px;
            top: 18px;
            width: 30px;
            height: 30px;
            background: white; /* 設定按鈕背景為白色 */
            font-weight: bold;
            text-align: center;
            border-radius: 50%; /* 讓按鈕變成圓形 */
            cursor: pointer;
            line-height: 30px; /* 讓文字垂直置中 */
            border: 2px solid black; /* 增加黑色邊框，讓按鈕更清楚 */
            transition: transform 0.3s ease-in-out;
        }

            .info-button:hover {
                transform: scale(1.1); /* 放大1.1倍 + 旋轉20度 */
            }
        /* ✅ 中央提示框外層（背景半透明） */
        .info-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: rgba(0,0,0,0.5);
            z-index: 10001;
        }
        /* ✅ 提示框本體 */
        .info-modal-content {
            background-color: #fff7e6;
            /*border: 3px solid red !important;*/
            border-radius: 15px;
            padding: 30px;
            width: 450px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.4);
            position: relative;
            text-align: left;
        }

        /* ===== 📌 提示視窗：右上角的關閉按鈕樣式 ===== */
        .info-modal-close {
            position: absolute; /* 固定在父元素的右上角 */
            top: 10px; /* 距離上方 10px */
            right: 15px; /* 距離右側 15px */
            font-size: 22px; /* 字體大小 */
            font-weight: bold; /* 粗體字 */
            color: #333; /* 深灰色字體 */
            cursor: pointer; /* 滑鼠變成手指 */
            transition: 0.3s; /* 滑鼠懸停時有動畫過渡 */
        }

            .info-modal-close:hover {
                color: #e74c3c; /* 懸停時變成紅色 */
                transform: scale(1.2); /* 略為放大 */
            }

        /* ===== 📌 森林功能面板主框架（浮出的功能選單） ===== */
        .magic-forest-panel {
            position: fixed; /* 固定在畫面中央 */
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%); /* 完全置中 */
            background-color: #fff7e6; /* 淡黃色背景 */
            border: 3px solid #d2b48c; /* 褐色邊框 */
            border-radius: 15px; /* 圓角 */
            padding: 30px; /* 內距 */
            z-index: 9999; /* 層級非常高，壓過其他 UI */
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.4); /* 外陰影 */
            width: 400px; /* 固定寬度 */
            text-align: center; /* 內容置中 */
        }

        /* 標題樣式（森林功能面板內的 h3） */
        .forest-panel-content h3 {
            font-weight: bold; /* 加粗 */
            margin-bottom: 20px; /* 下方留空 */
        }

        /* ===== 📌 森林功能面板右上角關閉叉叉 ===== */
        .forest-close {
            position: absolute; /* 固定位置在右上角 */
            top: 10px;
            right: 15px;
            width: 36px; /* 按鈕大小 */
            height: 36px;
            border-radius: 50%; /* 圓形按鈕 */
            color: #444; /* 按鈕顏色 */
            font-size: 20px; /* 字體大小 */
            font-weight: bold; /* 粗體 */
            display: flex; /* 置中內容 */
            justify-content: center;
            align-items: center;
            cursor: pointer; /* 滑鼠為手指 */
            transition: all 0.3s ease-in-out; /* 動畫過渡 */
        }

            .forest-close:hover {
                box-shadow: 0 0 12px rgba(255, 100, 100, 0.8); /* 懸停時出現紅色光暈 */
                transform: scale(1.1); /* 略為放大 */
            }

            /* ✨ 滑鼠懸停時出現光暈效果 */
            .forest-close:hover {
                box-shadow: 0 0 12px rgba(255, 100, 100, 0.8); /* 紅色光暈，可自定顏色 */
                transform: scale(1.1);
            }

        /* ✅ 祭壇選擇儀表板（置中浮出） */
        .altar-options-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 500px;
            background-color: #fffaf0;
            border: 3px solid #deb887;
            border-radius: 20px;
            box-shadow: 0 0 20px rgba(139, 69, 19, 0.4);
            padding: 30px;
            z-index: 10002;
            display: none;
        }

        /* 儀表板內部排版 */
        .altar-options-content {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 15px;
        }

        /* 🔶 祭壇選擇儀表板右上角的關閉按鈕樣式（叉叉） */
        .altar-close {
            position: absolute; /* 絕對定位（靠右上） */
            top: 10px; /* 距離頂部 10px */
            right: 15px; /* 距離右邊 15px */
            width: 36px; /* 按鈕寬度 */
            height: 36px; /* 按鈕高度 */
            border-radius: 50%; /* 圓形按鈕 */
            color: #444; /* 字體深灰色 */
            font-size: 20px; /* 字體大小 */
            font-weight: bold; /* 粗體字 */
            display: flex; /* 彈性盒子置中內容 */
            justify-content: center; /* 水平置中 */
            align-items: center; /* 垂直置中 */
            cursor: pointer; /* 滑鼠變成手指 */
            transition: all 0.3s ease-in-out; /* 滑動過渡動畫 */
        }

            .altar-close:hover {
                box-shadow: 0 0 12px rgba(255, 100, 100, 0.8); /* 懸停時出現紅色光暈 */
                transform: scale(1.1); /* 放大效果 */
            }

        /* 🔶 儀表板上方：標題與天數提示的外層容器 */
        .altar-header {
            position: relative; /* 讓子元素可以絕對定位 */
            width: 100%; /* 滿版寬度 */
            height: 40px; /* 固定高度 */
        }

        /* 🔶 儀表板標題「祭壇 X」 */
        .altar-title-text {
            position: absolute; /* 絕對定位於中間 */
            left: 50%; /* 從中間開始 */
            transform: translateX(-50%); /* 向左位移自身一半達成置中 */
            font-weight: bold; /* 粗體 */
            font-size: 24px; /* 字體大小 */
            color: #6b4226; /* 咖啡色 */
        }

        /* 🔶 儀表板右上角顯示幾天未複習 */
        .altar-days-text {
            position: absolute; /* 絕對定位 */
            left: calc(50% + 110px); /* 相對中間再偏右 110px */
            top: 2px; /* 距頂 2px */
            font-size: 20px; /* 字體大小 */
            color: #999; /* 淡灰色 */
            font-weight: 500; /* 中粗體 */
        }

        /* 🔶 南瓜進度列（祭壇進度條） */
        .altar-progress {
            display: flex; /* 彈性排版 */
            justify-content: center; /* 水平置中 */
            align-items: center; /* 垂直置中 */
            flex-wrap: nowrap; /* 不換行 */
            margin: 20px auto; /* 上下間距 + 水平置中 */
            gap: 0px; /* 無額外間距 */
        }

        /* 🔶 南瓜圖片（小 icon） */
        .altar-pumpkin {
            width: 36px; /* 寬度固定 */
            height: auto; /* 自動高度 */
            transition: transform 0.3s; /* 放大縮小動畫 */
        }

            .altar-pumpkin:hover {
                transform: scale(1.1); /* 懸停放大 */
            }

        /* 🔶 南瓜之間的連線圖片 */
        .altar-line {
            width: 24px; /* 寬度 */
            height: auto; /* 自動高度 */
            margin: 0 2px; /* 左右間距 */
        }

        /* 🔶 為了讓南瓜與線圖片緊密貼合的負邊距 */
        .altar-line, .altar-pumpkin {
            margin-left: -0.55px; /* 負值讓圖形貼近 */
            margin-right: -0.55px;
        }

        /* 🔶 儀表板下方中央按鈕（攻略／充能／複習） */
        .altar-button-action {
            font-size: 20px; /* 字體大小 */
            padding: 10px 30px; /* 上下10px，左右30px */
            border-radius: 25px; /* 橢圓形按鈕 */
            background-color: #6b4226; /* 咖啡色背景 */
            border: none; /* 無邊框 */
            color: white; /* 白色文字 */
            font-weight: bold; /* 粗體 */
            cursor: pointer; /* 滑鼠為手指 */
            transition: all 0.3s ease-in-out; /* 動畫過渡 */
        }

            .altar-button-action:hover {
                background-color: #8b5a2b; /* 滑鼠懸停變亮一點 */
            }

        /* 🔶 單字圖示（顯示卷軸按鈕） */
        .vocab-icon {
            width: 50px; /* 圖示寬度 */
            height: auto; /* 自動高度 */
            cursor: pointer; /* 滑鼠為手指 */
            transition: transform 0.3s ease-in-out; /* 放大動畫 */
        }

            .vocab-icon:hover {
                transform: scale(1.1); /* 放大效果 */
            }

        /* 🔶 卷軸浮出區塊（遮罩 + 卷軸內容） */
        .scroll-overlay {
            position: fixed; /* 固定在畫面最上層 */
            top: 0;
            left: 0;
            width: 100vw; /* 滿版寬度 */
            height: 100vh; /* 滿版高度 */
            background: rgba(0, 0, 0, 0.5); /* 半透明黑底 */
            z-index: 10003; /* 高層級 */
            display: flex; /* 彈性置中 */
            justify-content: center;
            align-items: center;
            padding: 2vh 2vw; /* 四周留白避免貼邊 */
            box-sizing: border-box;
        }

        /* 🔶 單字詳細資訊面板（內部小卡浮出區域） */
        .word-detail-panel {
            background: #fffefc; /* 米白背景 */
            border-radius: 15px; /* 圓角 */
            box-shadow: 0 0 15px rgba(0,0,0,0.3); /* 外陰影 */
            padding: 20px 30px; /* 內距 */
            width: 600px; /* 固定寬度 */
            max-height: 90vh; /* 最多高度 */
            overflow-y: auto; /* 垂直捲動 */
            position: relative; /* 內部定位基準 */
        }

            /* 🔶 單字詳細面板的上方區塊（標題 + 收藏） */
            .word-detail-panel .scroll-header {
                justify-content: space-between; /* 左右兩側 */
                padding: 0 20px; /* 左右內距 */
            }

            /* 🔶 詳細面板的關閉叉叉按鈕 */
            .word-detail-panel .scroll-close {
                position: absolute; /* 左上角固定位置 */
                top: 10px;
                left: 15px;
            }

        /* ✅ 卷軸本體（背景、框線與內部 padding 設定） */
        .scroll-panel {
            width: 80%; /* 滿寬 */
            height: 100%; /* 滿高 */
            background: linear-gradient(to bottom right, #f7f1e3, #e4dcc9, #d0c8a0); /* 漸層背景：魔法森林風格 */
            border-radius: 10px; /* 圓角 */
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3); /* 外陰影 */
            padding: 0 20px 20px 20px; /* 上右下左 padding */
            overflow-y: auto; /* 垂直可滾動 */
            overflow-x: hidden; /* 隱藏水平捲軸 */
            position: relative; /* 供內部定位參考 */
            box-sizing: border-box; /* 包含 padding 與 border */
        }

        /* ✅ 卷軸上方標題列 + 關閉按鈕（固定頂部） */
        .scroll-header {
            width: 450px; /* 固定寬度，與卡片一致 */
            margin: 0 auto; /* 水平置中 */
            position: sticky; /* 捲動時固定上方 */
            top: 0; /* 貼齊頂部 */
            background-color: #fefefe; /* 白色背景，避免透出後方 */
            z-index: 10; /* 疊層高 */
            height: 50px; /* 高度固定 */
            display: flex; /* 彈性容器 */
            align-items: center; /* 垂直置中 */
            justify-content: flex-end; /* 右對齊（關閉按鈕） */
            padding: 0 20px; /* 左右 padding */
            border-bottom: 2px solid #ddd; /* 下邊框 */
            border-top-left-radius: 10px; /* 左上角圓角 */
            border-top-right-radius: 10px; /* 右上角圓角 */
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); /* 底部陰影 */
        }

        /* ✅ 卷軸標題文字 */
        .scroll-title {
            position: absolute; /* 絕對定位（不影響彈性排版） */
            left: 50%; /* 從中間開始 */
            transform: translateX(-50%); /* 向左平移自身寬度一半 */
            font-size: 22px; /* 字體大小 */
            font-weight: bold; /* 粗體 */
            color: #444; /* 深灰色 */
        }

        /* ✅ 卷軸關閉按鈕（❌） */
        .scroll-close {
            position: absolute; /* 絕對定位 */
            top: 10px; /* 距頂 10px */
            left: 10px; /* 靠左 10px */
            font-size: 26px; /* 字體大小 */
            font-weight: bold; /* 粗體 */
            cursor: pointer; /* 滑鼠為手指 */
            color: #444; /* 深灰色 */
            transition: 0.3s; /* 過渡動畫 */
        }

            .scroll-close:hover {
                color: red; /* 滑鼠懸停變紅 */
                transform: scale(1.1); /* 放大效果 */
            }

        /* ✅ 卷軸內部：所有單字卡片的容器 */
        .scroll-words-container {
            display: flex; /* 彈性排版 */
            flex-direction: column; /* 垂直排列 */
            height: 420px;
            gap: 15px; /* 卡片間距 */
            margin-top: 20px; /* 距離標題列的間距 */
        }

        /* ✅ 每張單字卡片（內部一列） */
        .scroll-word-card {
            display: flex; /* 彈性排版（橫向） */
            justify-content: space-between; /* 左右對齊 */
            align-items: center; /* 垂直置中 */
            border: 2px solid #ddd; /* 淺灰框線 */
            border-radius: 12px; /* 圓角 */
            padding: 15px; /* 內距 */
            position: relative; /* 為絕對定位元素做參考 */
            width: 450px; /* 固定寬度 */
            margin: 0 auto; /* 水平置中 */
            background-color: #ffffffee; /* 淡白底（透明一點） */
        }

        /* ✅ 卡片左側文字區塊 */
        .word-left {
            display: flex;
            flex-direction: column;
            min-width: 100%; /* 撐滿父層 */
            box-sizing: border-box;
        }

            /* ✅ 單字文字（左側） */
            .word-left .word {
                font-size: 20px;
                color: #6b4226; /* 咖啡色 */
                font-weight: bold;
            }

            /* ✅ 詞性 / 翻譯資訊 */
            .word-left .info {
                margin-top: 5px;
                font-size: 16px;
            }

        /* ✅ 右上角愛心（收藏用） */
        .word-fav {
            position: absolute;
            top: 10px;
            right: 10px;
            width: 26px;
            height: auto;
            cursor: pointer;
            transition: transform 0.3s ease-in-out;
        }

            .word-fav:hover {
                transform: scale(1.1);
            }

        /* ✅ 飛心動畫（收藏動畫） */
        @keyframes fly-heart {
            0% {
                opacity: 1;
                transform: scale(1) translateY(0);
            }

            100% {
                opacity: 0;
                transform: scale(1.5) translateY(-80px);
            }
        }

        /* ✅ 飛心動畫圖示（從卡片飛起來） */
        .fly-heart {
            position: fixed; /* 整個畫面定位 */
            width: 26px;
            height: 26px;
            pointer-events: none; /* 不影響滑鼠事件 */
            animation: fly-heart 0.8s ease-out forwards; /* 執行動畫 */
            z-index: 88888; /* 超高層級 */
        }

        /* ✅ 單字與語音 ICON 的容器（左右對齊） */
        .word-audio-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
        }

        /* ✅ 單字文字區域（會被縮略） */
        .word-text-wrapper {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* ✅ 單字語音圖示 */
        .word-audio-icon {
            width: 28px;
            height: auto;
            flex-shrink: 0; /* 不縮小 */
            margin-left: 10px;
        }

        /* ✅ 字體本體（加粗） */
        .word-text {
            font-weight: bold;
            font-size: 20px;
            color: #6b4226;
        }

        /* ✅ 卡片右下角圖示列（愛心、語音、詳細資訊） */
        .word-icons {
            position: absolute;
            right: 10px;
            bottom: 10px;
            display: flex;
            gap: 10px;
        }

            .word-icons img {
                width: 26px;
                height: auto;
                cursor: pointer;
                transition: 0.2s;
            }

                .word-icons img:hover {
                    transform: scale(1.1);
                }

        /* ✅ 詳細面板中卡片排版：垂直顯示內容 */
        #pnlWordDetail .scroll-word-card {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            border: 2px solid #ddd;
            border-radius: 12px;
            width: 450px;
            margin: 0 auto;
            background-color: #ffffffee;
            box-sizing: border-box;
            gap: 8px;
        }

        /* ✅ 詳細面板內的愛心 icon */
        #pnlWordDetail .word-fav {
            height: auto;
            width: 32px;
            top: 10px;
            right: 18.25px; /* 自訂偏移量 */
        }

        /* ✅ 詳細面板內的語音 icon（固定右上角） */
        #pnlWordDetail .word-audio-icon {
            width: 32px;
            height: auto;
            position: absolute;
            top: 15px;
            right: 15px;
            cursor: pointer;
            transition: transform 0.3s ease-in-out;
        }

            #pnlWordDetail .word-audio-icon:hover {
                transform: scale(1.1);
            }

        /* ✅ 詳細面板內的單字文字區塊（右側預留 icon 空間） */
        #pnlWordDetail .word-text-wrapper {
            width: 100%;
            padding-right: 36px;
            box-sizing: border-box;
        }

        .part-of-speech-badge {
            display: inline-flex; /* ✅ 改用 inline-flex 讓內部內容能對齊 */
            justify-content: center; /* 水平置中 */
            align-items: center; /* 垂直置中 */
            width: 45px; /* 固定寬度 */
            height: 21px; /* ✅ 統一高度，避免因為內容長短而高低不一 */
            background-color: #6b4226;
            color: white;
            font-size: 14px;
            font-weight: bold;
            border-radius: 6px;
            margin: -2px 6px -2px 0; /* 上右下左，壓縮上下空間 */
        }

        .word-detail-footer {
            position: relative;
            z-index: 10;
        }

        /* 預設箭頭朝右 */
        img[src*='arrow-right'] {
            transform: rotate(0deg);
            transition: transform 0.3s ease;
        }

        /* 點擊後箭頭向下 */
        img[src*='arrow-down'] {
            transform: rotate(90deg);
            transition: transform 0.3s ease;
        }

        /* 預設動畫 */
        .expand-toggle {
            transition: transform 0.3s ease-in-out;
        }

            /* 展開狀態（箭頭朝下） */
            .expand-toggle.expanded {
                transform: rotate(90deg);
            }

                /* hover 狀態下：如果是展開的，放大＋保持向下 */
                .expand-toggle.expanded:hover {
                    transform: scale(1.1) rotate(90deg);
                }

            /* hover 狀態下：如果是收起的，放大＋保持向右 */
            .expand-toggle:hover:not(.expanded) {
                transform: scale(1.1) rotate(0deg);
            }

        /* ✅ 英文例句區容器（句子 + 語音） */
        .example-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            min-height: 30px;
            min-width: 200px;
            gap: 10px;
            box-sizing: border-box;
        }

        /* ✅ 例句語音圖示（靠右） */
        .sentence-audio-icon {
            width: 32px;
            height: auto;
            cursor: pointer;
            transition: transform 0.3s ease-in-out;
        }

            .sentence-audio-icon:hover {
                transform: scale(1.1);
            }

        .scroll-arrow {
            width: 32px;
            height: auto;
            cursor: pointer;
            transition: filter 0.3s ease-in-out, transform 0.1s ease-in-out;
        }

            .scroll-arrow:hover {
                filter: brightness(1.4); /* 懸停時變亮 */
            }

            .scroll-arrow:active {
                transform: scale(0.95); /* 按下時微微縮小 */
            }

        .word-position {
            font-weight: bold;
            font-size: 16px;
        }
    </style>
    <script>
        function showAltarOptions(altarId) {
            console.log("🎯 點到祭壇 ID:", altarId);

            // 存進 hidden 欄位
            document.getElementById("hiddenAltarId").value = altarId;

            // 從頁面抓 userId（Session 已存在）
            const userId = parseInt(document.getElementById("hiddenUserId").value);

            fetch("AltarService.asmx/GetAltarStatus", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                credentials: 'include',
                body: JSON.stringify({ altarId: altarId })
            })
                .then(response => response.json())
                .then(result => {
                    const data = result.d;

                    if (data.error === "NOT_LOGGED_IN") {
                        alert("請先登入！");
                        return;
                    }

                    // 傳給你原本的 showAltarPanel（✅ 不改你原本的參數）
                    showAltarPanel(altarId, data.learningStatus, data.nextReviewTime);
                })
                .catch(error => {
                    console.error("❌ AJAX 發生錯誤：", error);
                });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
        <asp:HiddenField ID="hiddenUserId" runat="server" ClientIDMode="Static" />
        <div class="container-fluid">
            <!-- 🔹 狀態列 (從資料庫讀取) -->
            <div class="row">
                <div class="col-12" id="navbar">
                    <span class="resource">
                        <img src="images/energy.svg" alt="魔法能量" data-toggle="tooltip" title="魔法能量" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <asp:Label ID="lblEnergy" runat="server"></asp:Label>
                    </span>
                    <span class="resource">
                        <img src="images/diamond.svg" alt="魔法鑽石" data-toggle="tooltip" title="魔法鑽石" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <asp:Label ID="lblDiamonds" runat="server"></asp:Label>
                    </span>
                    <span class="resource">
                        <img id="volumeIcon" src="images/volume.svg" alt="背景音樂" data-toggle="tooltip" title="調整背景音樂(BGM)" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <input type="range" id="volumeSlider" min="0" max="1" step="0.01" value="0.5" title="調整音量" />
                    </span>
                    <!-- 音效音量控制 -->
                    <span class="resource" id="soundEffectControl">
                        <img id="soundEffectIcon" src="images/music-note-beamed.svg" alt="音效音量" data-toggle="tooltip" title="調整音效(按鈕聲/發音等)" style="width: 24px; height: 24px;" />
                        <input type="range" id="soundEffectSlider" min="0" max="1" step="0.01" value="1.0" title="調整音效音量" />
                    </span>
                </div>
            </div>
            <!-- 🔹 第一行 (森林選擇 & 祭壇儀表板) -->
            <div class="row">
                <!-- 🔹 左側 (col-md-1) 森林切換按鈕 -->
                <div class="col-md-1 forest-select-container">
                    <img id="forest-select" src="images/forestselect.svg" alt="切換森林" onclick="toggleForestPanel();" />
                </div>

                <!-- 🔹 右側 (col-md-11) 放置祭壇 & 告示牌 -->
                <div class="col-md-11 d-flex justify-content-center">
                    <div class="altar-container">
                        <!-- 告示牌 + INFO -->
                        <div class="billboard-container">
                            <img id="billboard" src="images/billboard.svg" alt="森林看板" />
                            <div class="forest-label">
                                <asp:Label ID="lblForestName" runat="server"></asp:Label>
                            </div>
                            <span class="info-button" onclick="showInfoModal()">i</span>
                        </div>

                        <!-- ✅ 🔽 新增：森林功能儀表板 (會在點選圖示後浮出) -->
                        <div id="forestOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.4); z-index: 10000;">
                            <asp:Panel ID="pnlMagicForest" runat="server" ClientIDMode="Static" CssClass="magic-forest-panel">
                                <div class="forest-panel-content">
                                    <!-- 叉叉關閉 -->
                                    <span class="forest-close" onclick="closeForestPanel()">&times;</span>
                                    <!-- 面板標題 -->
                                    <h3>森林功能面板</h3>
                                    <!-- 三個按鈕 -->
                                    <asp:Button ID="btnSwitchForest" runat="server" Text="切換森林" CssClass="btn btn-primary m-2"
                                        OnClientClick="stopBGM();" OnClick="btnSwitchForest_Click" />
                                    <asp:Button ID="btnBackHome" runat="server" Text="返回首頁" CssClass="btn btn-secondary m-2"
                                        OnClientClick="stopBGM();" OnClick="btnBackHome_Click" />
                                    <asp:Button ID="btnViewStats" runat="server" Text="查看統計" CssClass="btn btn-info m-2"
                                        OnClientClick="stopBGM();" OnClick="btnViewStats_Click" />
                                </div>
                            </asp:Panel>
                        </div>


                        <!-- !-- ✅ 🔽 新增：祭壇儀表板 (永遠顯示在UI，每個LEVEL裡面都包含100顆按鈕) -->
                        <asp:Panel ID="pnlMagicAltar" runat="server" Visible="true" CssClass="altar-grid">
                            <asp:Literal ID="litAltarGrid" runat="server"></asp:Literal>
                        </asp:Panel>

                        <!-- ✅ 🔽 新增：祭壇選擇儀表板（點選祭壇按鈕後顯示） -->
                        <asp:UpdatePanel ID="UpdatePanelAltar" runat="server">
                            <ContentTemplate>
                                <div id="altarOptionsOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.3); z-index: 10001;">
                                    <asp:Panel ID="pnlAltarOptions" runat="server" ClientIDMode="Static" CssClass="altar-options-panel" Style="display: none;">
                                        <div class="altar-options-content">
                                            <!-- 🔴 右上角叉叉關閉按鈕 -->
                                            <span class="altar-close" onclick="closeAltarOptions()">×</span>
                                            <!-- 上方：祭壇資訊 -->
                                            <div class="altar-header">
                                                <span id="altarTitle" class="altar-title-text">祭壇209</span>
                                                <span id="daysSinceReview" class="altar-days-text">5 天未複習</span>
                                            </div>
                                            <!-- 中段：進度南瓜與連接線 -->
                                            <div class="altar-progress" id="pumpkinProgress">
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                            </div>
                                            <!-- 下方：單字圖標 & 攻略按鈕 -->
                                            <div style="position: relative; width: 100%; height: 60px;">
                                                <img src="images/vocabulary.svg" class="vocab-icon" style="position: absolute; left: 10px; bottom: 0;" onclick="showAncientScrollPanel()" />
                                                <button class="altar-button-action" style="position: absolute; left: 130px; bottom: 0; width: 180px;" onclick="alert('點了攻略按鈕')">攻略</button>
                                            </div>

                                        </div>
                                    </asp:Panel>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:HiddenField ID="hiddenAltarId" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
            </div>
        </div>

        <!-- ✅ 🔽 新增：卷軸儀表板（預設隱藏） -->
        <div id="pnlAncientScroll" class="scroll-overlay" style="display: none;">
            <div class="scroll-panel">
                <!-- 上方區塊 -->
                <div class="scroll-header">
                    <div class="scroll-title">祭壇 1</div>
                    <span class="scroll-close" onclick="closeScrollPanel()">&times;</span>
                </div>
                <!-- 單字清單 -->
                <div id="pnlScrollWords" class="scroll-words-container">
                    <!-- 單字項目會由 JavaScript 動態插入 -->
                </div>
            </div>
        </div>

        <!-- ✅ 🔽 新增：單字詳細資訊儀表板（遮罩 + 單字卡） -->
        <div id="pnlWordDetail" class="scroll-overlay" style="display: none;">
            <!-- 小卡浮出中央 -->
            <div class="word-detail-panel">

                <!-- 上方叉叉與愛心收藏 -->
                <div class="scroll-header">
                    <span class="scroll-close" onclick="closeWordDetailPanel()">&times;</span>
                    <img id="favIcon" class="word-fav" src="images/heartwithnocolor.svg" title="加入收藏" />
                </div>

                <!-- 詳細內容 -->
                <div id="pnlWordDetailContent" class="scroll-words-container">
                    <!-- 動態插入 -->
                </div>

                <!-- 導覽列與地點 -->
                <div class="word-detail-footer" style="display: flex; flex-direction: column; justify-content: center; align-items: center; gap: 10px; margin-top: 15px;">

                    <!-- 🔁 上下切換 + 頁碼區（橫向排列 + 分開一點） -->
                    <div style="display: flex; justify-content: center; align-items: center; gap: 20px;">
                        <img id="btnPrevWord" src="images/arrow-pointing-Upward.svg"
                            class="scroll-arrow" title="上一個" />

                        <span id="wordPosition" class="word-position">1 / 1</span>

                        <img id="btnNextWord" src="images/arrow-pointing-Downward.svg"
                            class="scroll-arrow" title="下一個" />
                    </div>

                </div>

                <!-- 📍 顯示單字位置的說明 -->
                <div style="text-align: center; font-size: 14px; color: #555;">
                    <span id="wordLocation">位於：森林？ 祭壇？</span>
                </div>
            </div>

        </div>
        </div>

    </form>
    <!-- ✅ 遊戲介紹提示框 -->
    <div id="infoModal" class="info-modal d-none">
        <div class="info-modal-content">
            <span class="info-modal-close" onclick="closeInfoModal()">&times;</span>
            <h4>🌟 遊戲玩法說明</h4>
            <p>
                歡迎來到「森林詞彙魔法祭壇」！<br />
                <br />
                🔸 每座祭壇代表一組單字關卡。<br />
                🔸 點擊祭壇可選擇「學習單字」或「開始測驗」。<br />
                🔸 完成學習與測驗後會獲得魔法能量與鑽石！<br />
                <br />
                點擊左側的森林圖示可以切換不同詞彙主題 🌲。
            </p>
        </div>
    </div>
    <!-- jQuery（Bootstrap 4 相依） -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <!-- Popper.js（Tooltip 需要） -->
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <!-- Bootstrap 4 JS -->
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <script>
        $(function () {
            $('[data-toggle="tooltip"]').tooltip();
        });
    </script>

    <script>
        // 顯示森林儀表板
        function toggleForestPanel() {
            const overlay = document.getElementById("forestOverlay");
            const altarPanel = document.getElementById("pnlAltarOptions");

            // 顯示森林面板與遮罩
            if (overlay) {
                overlay.style.display = "block";
            }

            // 同時關掉祭壇面板
            if (altarPanel) {
                altarPanel.style.display = "none";
            }
        }

        function closeForestPanel() {
            const overlay = document.getElementById("forestOverlay");
            if (overlay) {
                overlay.style.display = "none";
            }
        }
    </script>

    <audio id="bgm" src="musics/ScentOfForest.mp3" autoplay loop></audio>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const audio = document.getElementById("bgm");
            const volumeSlider = document.getElementById("volumeSlider");
            const volumeIcon = document.getElementById("volumeIcon");

            // 1️⃣ 從 sessionStorage 取出記錄的音量與播放狀態
            const savedVolume = sessionStorage.getItem("bgmVolume");
            const shouldPlay = sessionStorage.getItem("bgmShouldPlay");

            // 設定音量
            if (savedVolume !== null) {
                audio.volume = parseFloat(savedVolume);
                volumeSlider.value = savedVolume;
            } else {
                audio.volume = 0.5; // 預設音量
                volumeSlider.value = 0.5;
            }

            // 初始化圖示
            function updateVolumeIcon(volume) {
                volumeIcon.src = volume == 0 ? "images/volume0.svg" : "images/volume.svg";
            }
            updateVolumeIcon(audio.volume);

            // 音量滑桿變動時
            volumeSlider.addEventListener("input", function () {
                const newVolume = parseFloat(this.value);
                audio.volume = newVolume;
                sessionStorage.setItem("bgmVolume", newVolume); // ⚠ 儲存音量
                updateVolumeIcon(newVolume);
            });

            // 2️⃣ 如果之前是播放狀態，則恢復播放
            if (shouldPlay === "true") {
                audio.play().catch(() => { });
            }

            // 3️⃣ 監聽播放與暫停事件，紀錄狀態
            audio.addEventListener("play", () => {
                sessionStorage.setItem("bgmShouldPlay", "true");
            });
            audio.addEventListener("pause", () => {
                sessionStorage.setItem("bgmShouldPlay", "false");
            });
        });
        function showInfoModal() {
            document.getElementById("infoModal").classList.remove("d-none");
        }

        function closeInfoModal() {
            document.getElementById("infoModal").classList.add("d-none");
        }
    </script>

    <script>
        function stopBGM() {
            const audio = document.getElementById("bgm");
            if (audio) {
                audio.pause();
                sessionStorage.setItem("bgmShouldPlay", "false"); // ❗ 確保狀態儲存
                audio.src = "";  // 關鍵：清掉音源，讓瀏覽器以為沒有聲音了
                audio.load();    // 強迫重新載入，觸發「音訊已停止」
            }
        }
    </script>

    <!-- ✅ ✅ ✅ 已整合語音音量控制邏輯 -->
    <script>
        // 全局音效音量變數（供所有音效 & TTS 使用）
        let soundEffectVolume = 1.0;

        document.addEventListener("DOMContentLoaded", function () {
            const sfxSlider = document.getElementById("soundEffectSlider");
            const sfxIcon = document.getElementById("soundEffectIcon");

            // 還原音量
            const savedSfxVolume = sessionStorage.getItem("sfxVolume");
            if (savedSfxVolume !== null) {
                soundEffectVolume = parseFloat(savedSfxVolume);
                sfxSlider.value = soundEffectVolume;
            }

            function updateSfxIcon(volume) {
                sfxIcon.src = volume == 0
                    ? "images/music-note-beamed-novolume.svg"
                    : "images/music-note-beamed.svg";
            }

            updateSfxIcon(soundEffectVolume);

            sfxSlider.addEventListener("input", function () {
                soundEffectVolume = parseFloat(this.value);
                sessionStorage.setItem("sfxVolume", soundEffectVolume);
                updateSfxIcon(soundEffectVolume);
            });
        });

        // ✅ 公用播放音效（包含 mp3 音效）
        function playSoundEffect(src) {
            const audio = new Audio(src);
            audio.volume = soundEffectVolume;
            audio.play().catch(err => {
                console.error("播放音效失敗：", err);
            });
        }
    </script>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // 祭壇遮罩關閉
            const altarOverlay = document.getElementById("altarOptionsOverlay");
            altarOverlay?.addEventListener("click", function (e) {
                if (e.target === altarOverlay) {
                    closeAltarOptions();
                }
            });

            // 卷軸遮罩關閉
            const scrollOverlay = document.getElementById("pnlAncientScroll");
            scrollOverlay?.addEventListener("click", function (e) {
                if (e.target === scrollOverlay) {
                    closeScrollPanel();
                }
            });

            // ✅ 森林遮罩關閉（正確）
            const forestOverlay = document.getElementById("forestOverlay");
            forestOverlay?.addEventListener("click", function (e) {
                if (e.target === forestOverlay) {
                    closeForestPanel();
                }
            });

            // 遊戲說明關閉
            const infoModal = document.getElementById("infoModal");
            infoModal?.addEventListener("click", function (e) {
                if (e.target === infoModal) {
                    infoModal.classList.add("d-none");
                }
            });
        });

        // ✅ 單字詳細資訊遮罩點擊關閉
        const detailOverlay = document.getElementById("pnlWordDetail");
        detailOverlay?.addEventListener("click", function (e) {
            if (e.target === detailOverlay) {
                closeWordDetailPanel();
            }
        });
    </script>

    <script>
        function closeAltarOptions() {
            document.getElementById("altarOptionsOverlay").style.display = "none";
        }

        document.addEventListener("DOMContentLoaded", function () {
            // ✅ 點擊遮罩關閉祭壇儀表板
            const overlay = document.getElementById("altarOptionsOverlay");
            const panel = document.getElementById("pnlAltarOptions");

            overlay.addEventListener("click", function (e) {
                if (e.target === overlay) {
                    closeAltarOptions();
                }
            });

            // ✅ 防止攻略按鈕觸發表單提交（避免 BGM 中斷）
            const buttons = document.querySelectorAll(".altar-button-action");
            buttons.forEach(btn => {
                btn.addEventListener("click", function (event) {
                    event.preventDefault();
                });
            });
        });

        // ✅ 顯示祭壇儀表板（更新為顯示整個 overlay）
        function showAltarPanel(altarId, learningStatus, nextReviewTimeStr) {
            document.getElementById("altarOptionsOverlay").style.display = "block";
            document.getElementById("pnlAltarOptions").style.display = "block"; // 🟢 加這一行，顯示儀表板
            document.getElementById("altarTitle").textContent = "祭壇 " + altarId;

            const daysLabel = document.getElementById("daysSinceReview");
            if (!nextReviewTimeStr) {
                daysLabel.textContent = "尚未學習";
            } else {
                const nextTime = new Date(nextReviewTimeStr);
                const now = new Date();
                const diffMs = now - nextTime;

                if (diffMs < 0) {
                    const totalSeconds = Math.floor(-diffMs / 1000);
                    const hours = Math.floor(totalSeconds / 3600);
                    const minutes = Math.floor((totalSeconds % 3600) / 60);
                    daysLabel.textContent = `澆水：${hours}時${minutes}分`;
                } else {
                    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
                    daysLabel.textContent = `${days} 天未複習`;
                }
            }

            const actionButton = document.querySelector(".altar-button-action");
            if (learningStatus === 0) {
                actionButton.textContent = "攻略";
            } else if (learningStatus >= 1 && learningStatus < 7) {
                actionButton.textContent = "充能";
            } else if (learningStatus === 999 || learningStatus >= 7) {
                actionButton.textContent = "複習";
            }
        }
    </script>

    <script>
        // ✅ 全域單字陣列，供卷軸 & 詳細資訊共用（關鍵）
        let scrollWords = [];

        // ✅ 顯示卷軸面板
        function showAncientScrollPanel() {
            const altarId = parseInt(document.getElementById("hiddenAltarId").value);
            const panel = document.getElementById("pnlAncientScroll");
            const container = document.getElementById("pnlScrollWords");

            // ✅ 1️. 更新卷軸標題文字
            document.querySelector(".scroll-title").textContent = `祭壇 ${altarId}`;

            // ✅ 2️. 顯示卷軸面板
            panel.style.display = "flex";
            container.innerHTML = "";

            fetch("ScrollService.asmx/GetScrollWords", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                credentials: "include",
                body: JSON.stringify({ altarId: altarId })
            })
                .then(res => res.json())
                .then(result => {
                    scrollWords = result.d; // ✅ 存入全域變數，供詳細資訊共用
                    if (scrollWords.length === 0) {
                        container.innerHTML = "<p>⚠ 尚無單字資料。</p>";
                        return;
                    }

                    scrollWords.forEach((w, i) => {
                        const card = document.createElement("div");
                        card.className = "scroll-word-card";

                        const favImg = document.createElement("img");
                        favImg.className = "word-fav";
                        favImg.src = w.is_favorite ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";

                        favImg.onclick = () => {
                            const latest = scrollWords.find(item => item.scroll_id === w.scroll_id);
                            if (!latest) return;

                            const newFav = !latest.is_favorite;
                            latest.is_favorite = newFav;

                            favImg.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                            toggleFavorite(w.scroll_id, newFav);
                            if (newFav) showFlyingHeart(favImg);
                        };

                        card.appendChild(favImg);

                        const left = document.createElement("div");
                        left.className = "word-left";
                        left.innerHTML = `
                        <span class="word">${w.word}</span>
                        <span class="info"><span class="badge badge-secondary">${w.part_of_speech}</span> ${w.meaning}</span>
                    `;
                        card.appendChild(left);

                        const icons = document.createElement("div");
                        icons.className = "word-icons";

                        const infoIcon = document.createElement("img");
                        infoIcon.src = "images/list-bullet.svg?v=" + new Date().getTime();
                        infoIcon.title = "查看詳情";
                        infoIcon.onclick = () => {
                            const forestId = parseInt('<%= Request.QueryString["level"] %>'); // ✅ 從 URL 抓 forestId
                            loadFullScrollWords(forestId, w.scroll_id); // ✅ 改用查整個森林
                        };
                        icons.appendChild(infoIcon);

                        const volIcon = document.createElement("img");
                        volIcon.src = "images/volumewithnocolor.svg?v=" + new Date().getTime();
                        volIcon.title = "播放單字";
                        volIcon.onclick = () => {
                            volIcon.src = "images/volumewithlightcolor.svg";
                            const utter = new SpeechSynthesisUtterance(w.word);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume;
                            speechSynthesis.speak(utter);
                            utter.onend = () => {
                                volIcon.src = "images/volumewithnocolor.svg";
                            };
                        };
                        icons.appendChild(volIcon);

                        card.appendChild(icons);
                        container.appendChild(card);
                    });
                })
                .catch(err => {
                    console.error("❌ 巻軸 AJAX 錯誤：", err);
                    container.innerHTML = "<p>⚠ 載入失敗。</p>";
                });
        }

        // ✅ 關閉卷軸面板
        function closeScrollPanel() {
            document.getElementById("pnlAncientScroll").style.display = "none";
        }

        // ✅ 收藏切換邏輯（動畫 + 傳送後端 + 切換圖片）
        function toggleFavorite(scrollId, isNowFav) {
            fetch("ScrollService.asmx/UpdateFavorite", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    scrollId: scrollId,
                    isFavorite: isNowFav
                })
            })
                .then(response => response.json())
                .then(data => {
                    console.log("✅ 收藏更新成功：", data.d);
                })
                .catch(err => {
                    console.error("❌ 收藏更新失敗：", err);
                });
        }

        //飛心動畫功能
        function showFlyingHeart(targetIcon) {
            const heart = document.createElement("img");
            heart.src = "images/heartwithredcolor.svg";
            heart.className = "fly-heart";

            const rect = targetIcon.getBoundingClientRect();
            heart.style.left = `${window.scrollX + rect.left + rect.width / 2 - 12}px`;
            heart.style.top = `${window.scrollY + rect.top + rect.height / 2 - 12}px`;

            // 🔁 不是 document.body，而是專用區域！
            const zone = document.getElementById("flyingEffectsZone");
            zone.appendChild(heart);

            void heart.offsetWidth;
            heart.style.animation = "fly-heart 0.8s ease-out forwards";

            setTimeout(() => {
                heart.remove();
            }, 800);
        }
    </script>

    <script>
        // ✅ 從整座森林中載入所有單字，並打開詳細資訊儀表板（可用上下箭頭切換 1000 字）
        function loadFullScrollWords(forestId, clickedScrollId) {
            // 🔁 發送 POST 請求給 ScrollService.asmx/GetAllScrollWordsByForest，取得該森林全部單字
            fetch("ScrollService.asmx/GetAllScrollWordsByForest", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ forestId: forestId }) // 傳入森林 ID 作為查詢條件
            })
                .then(res => res.json()) // 轉成 JSON 格式
                .then(result => {
                    speechSynthesis.cancel(); // 取消播放語音

                    // 🔥 把所有亮著的小喇叭 ICON 還原成灰色
                    document.querySelectorAll(".word-icons img[src*='volumewithlightcolor']").forEach(icon => {
                        icon.src = "images/volumewithnocolor.svg";
                    });

                    scrollWords = result.d;
                    const startIndex = scrollWords.findIndex(w => w.scroll_id === clickedScrollId);
                    if (startIndex !== -1) {
                        showWordDetailPanel(scrollWords, startIndex);
                    } else {
                        alert("❌ 找不到該單字位置");
                    }
                });

        }

        //此為顯示詳細單字資訊的方法
        function showWordDetailPanel(words, index) {
            const panel = document.getElementById("pnlWordDetail");
            const container = document.getElementById("pnlWordDetailContent");
            const posLabel = document.getElementById("wordPosition");
            const locLabel = document.getElementById("wordLocation");

            // ✅ 每次都清空容器（不只第一次）
            container.innerHTML = "";

            const card = document.createElement("div");
            card.className = "scroll-word-card";

            const left = document.createElement("div");
            left.className = "word-left";
            left.innerHTML = `
<div class="word-text-wrapper">
    <span id="wordText" class="word-text"></span>
</div>

<span id="pronunciationText" class="info"></span>
<span id="posMeaningText" class="info"></span>

<div id="tenseWrapper">
    <span id="tenseText" class="info"></span>
</div>

<div class="example-container">
    <span id="exampleText"></span>
</div>

<span id="translationText" class="info text-muted"></span>
`;

            card.appendChild(left);
            container.appendChild(card);

            // 插入單字發音 icon（右上角）
            const iconAudio = document.createElement("img");
            iconAudio.id = "iconWordAudio";
            iconAudio.className = "word-audio-icon";
            iconAudio.src = "images/volumewithnocolor.svg";
            card.appendChild(iconAudio);

            // 插入例句發音 icon（例句右側）
            const exampleContainer = left.querySelector(".example-container");
            const sentenceAudio = document.createElement("img");
            sentenceAudio.id = "iconSentenceAudio";
            sentenceAudio.className = "sentence-audio-icon";
            sentenceAudio.src = "images/volumewithnocolor.svg";
            exampleContainer.appendChild(sentenceAudio);

            let currentIndex = index;
            let lastScrollTime = 0; // 放這裡就好
            let isSpeaking = false;
            let hasWheelListener = false;

            // 💡 用來記住展開狀態的變數（true = 展開中，false = 收起）
            let isExpandedGlobally = false;

            // ✅ 更新單字卡片內容
            function updateCard(w) {
                currentIndex = words.findIndex(word => word.scroll_id === w.scroll_id);
                if (currentIndex === -1) return; // 萬一同步出問題就跳掉

                const wordAudio = document.getElementById("iconWordAudio");
                const sentenceAudio = document.getElementById("iconSentenceAudio");

                // 還原音效圖示狀態
                if (wordAudio) wordAudio.src = "images/volumewithnocolor.svg";
                if (sentenceAudio) sentenceAudio.src = "images/volumewithnocolor.svg";

                speechSynthesis.cancel(); // 取消先前語音播放

                fetch("ScrollService.asmx/GetWordDetail", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    credentials: "include",
                    body: JSON.stringify({ scrollId: w.scroll_id })
                })
                    .then(res => res.json())
                    .then(result => {
                        const items = result.d;
                        if (!Array.isArray(items) || items.length === 0) {
                            container.innerHTML = "<p>❌ 無法載入資料</p>";
                            return;
                        }

                        const verbEntry = items.find(i => i.part_of_speech.startsWith("v")) || {};
                        const base = items[0];

                        // 填入基本資訊
                        document.getElementById("wordText").innerText = base.word;
                        document.getElementById("pronunciationText").innerHTML = `<strong>${base.pronunciation}</strong>`;

                        const tenseElem = document.getElementById("tenseText");
                        const past1 = verbEntry.past_tense || "—";
                        const past2 = verbEntry.past_participle || "—";

                        if (past1 === "—" && past2 === "—") {
                            tenseElem.style.display = "none";
                        } else {
                            tenseElem.style.display = "block";
                            tenseElem.innerHTML = `過去式：${past1}<br/>過去分詞：${past2}`;
                        }

                        document.getElementById("exampleText").innerText = base.example_sentence;
                        document.getElementById("translationText").innerText = base.example_translation;
                        locLabel.textContent = base.location_text;
                        posLabel.textContent = `${currentIndex + 1} / ${words.length}`;

                        const meanings = items.map(item =>
                            `<span class="part-of-speech-badge">${item.part_of_speech}</span> ${item.meaning}`
                        ).join("<br/>");
                        document.getElementById("posMeaningText").innerHTML = meanings;

                        // 移除舊的展開區塊
                        const oldExpand = document.getElementById("expandWrapper");
                        if (oldExpand) oldExpand.remove();

                        // 建立展開區塊（同反衍）
                        const tenseWrapper = document.getElementById("tenseWrapper");
                        const expandWrapper = document.createElement("div");
                        expandWrapper.id = "expandWrapper";
                        expandWrapper.style.marginTop = "6px";

                        // 建立展開 icon 圖示
                        const toggleIcon = document.createElement("img");
                        toggleIcon.src = "images/more-svgrepo-com.svg";
                        toggleIcon.className = "expand-toggle";
                        toggleIcon.style.width = "24px";
                        toggleIcon.style.cursor = "pointer";

                        // 根據展開狀態加上 `.expanded` class（旋轉 90 度）
                        if (isExpandedGlobally) {
                            toggleIcon.classList.add("expanded");
                        } else {
                            toggleIcon.classList.remove("expanded");
                        }

                        // 建立展開內容區塊
                        const wordInfoDiv = document.createElement("div");
                        wordInfoDiv.style.marginTop = "8px";
                        wordInfoDiv.style.display = isExpandedGlobally ? "block" : "none";

                        // 建立單行項目（同/反/衍）
                        const createRow = (labelText, content) => {
                            const row = document.createElement("div");
                            const badge = document.createElement("span");
                            badge.className = "part-of-speech-badge";
                            badge.textContent = labelText;

                            const contentSpan = document.createElement("span");
                            contentSpan.textContent = content || "—";
                            contentSpan.style.marginLeft = "6px";

                            row.appendChild(badge);
                            row.appendChild(contentSpan);
                            return row;
                        };

                        // 加入內容區塊
                        wordInfoDiv.appendChild(createRow("同", base.synonym_words));
                        wordInfoDiv.appendChild(createRow("反", base.antonym_words));
                        wordInfoDiv.appendChild(createRow("衍", base.related_info));

                        // 點擊 toggle 展開 / 收合
                        toggleIcon.onclick = () => {
                            isExpandedGlobally = !isExpandedGlobally;
                            wordInfoDiv.style.display = isExpandedGlobally ? "block" : "none";
                            toggleIcon.classList.toggle("expanded", isExpandedGlobally);
                        };

                        // 最後插入 DOM
                        expandWrapper.appendChild(toggleIcon);
                        expandWrapper.appendChild(wordInfoDiv);
                        tenseWrapper.appendChild(expandWrapper);

                        // ❤️ 收藏圖示邏輯
                        const favIcon = document.getElementById("favIcon");
                        favIcon.src = w.is_favorite ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                        favIcon.onclick = () => {
                            const newFav = !w.is_favorite;
                            w.is_favorite = newFav;
                            words[currentIndex].is_favorite = newFav;

                            // ✅ 同步 scrollWords 陣列（已經有）
                            const target = scrollWords.find(item => item.scroll_id === w.scroll_id);
                            if (target) target.is_favorite = newFav;

                            // ✅ ✅ ✅ [新增] 同步更新卷軸卡片上的圖示
                            const scrollCards = document.querySelectorAll(".scroll-word-card");
                            scrollCards.forEach(card => {
                                const icon = card.querySelector(".word-fav");
                                const wordLabel = card.querySelector(".word-left .word");
                                if (wordLabel && wordLabel.textContent === w.word && icon) {
                                    icon.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                                }
                            });

                            // ✅ 換圖 + 傳後端
                            favIcon.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                            toggleFavorite(w.scroll_id, newFav);
                            if (newFav) showFlyingHeart(favIcon);
                        };

                        // 語音：單字
                        wordAudio.onclick = () => {
                            speechSynthesis.cancel();
                            wordAudio.src = "images/volumewithlightcolor.svg";
                            const utter = new SpeechSynthesisUtterance(base.word);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume;
                            speechSynthesis.speak(utter);
                            utter.onend = () => wordAudio.src = "images/volumewithnocolor.svg";
                        };

                        // 語音：例句
                        sentenceAudio.onclick = () => {
                            speechSynthesis.cancel();
                            sentenceAudio.src = "images/volumewithlightcolor.svg";
                            const utter = new SpeechSynthesisUtterance(base.example_sentence);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume;
                            speechSynthesis.speak(utter);
                            utter.onend = () => sentenceAudio.src = "images/volumewithnocolor.svg";
                        };

                        // ✅ 自動播放語音（進入卡片後延遲播放）
                        if (!isSpeaking) {
                            isSpeaking = true;
                            wordAudio.src = "images/volumewithlightcolor.svg";

                            setTimeout(() => {
                                const autoUtter = new SpeechSynthesisUtterance(base.word);
                                autoUtter.lang = "en-US";
                                autoUtter.volume = soundEffectVolume;
                                autoUtter.onend = () => {
                                    wordAudio.src = "images/volumewithnocolor.svg";
                                    isSpeaking = false;
                                };
                                autoUtter.onerror = () => { isSpeaking = false; };
                                speechSynthesis.speak(autoUtter);
                            }, 100);
                        }
                    });
            }

            // ✅ 確保滾輪事件只加一次
            function setupWheelScroll(panel, words, updateCardFunc) {
                if (panel.dataset.hasWheelListener === "true") return;

                panel.addEventListener("wheel", function (e) {
                    const now = Date.now();
                    if (now - lastScrollTime < 250) return;
                    lastScrollTime = now;
                    speechSynthesis.cancel();

                    if (e.deltaY > 0 && currentIndex < words.length - 1) {
                        currentIndex++;
                        updateCardFunc(words[currentIndex]);
                    } else if (e.deltaY < 0 && currentIndex > 0) {
                        currentIndex--;
                        updateCardFunc(words[currentIndex]);
                    }

                    e.preventDefault();
                }, { passive: false });

                panel.dataset.hasWheelListener = "true"; // 標記已加過滾輪事件
            }

            // 初始載入
            updateCard(words[currentIndex]);
            panel.style.display = "flex";
            setupWheelScroll(panel, words, updateCard);

            // 上下切換
            document.getElementById("btnPrevWord").onclick = () => {
                if (currentIndex > 0) {
                    currentIndex--;
                    updateCard(words[currentIndex]);
                }
            };
            document.getElementById("btnNextWord").onclick = () => {
                if (currentIndex < words.length - 1) {
                    currentIndex++;
                    updateCard(words[currentIndex]);
                }
            };
        }

        function closeWordDetailPanel() {
            document.getElementById("pnlWordDetail").style.display = "none";
        }
    </script>
    <div id="flyingEffectsZone" style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; pointer-events: none; z-index: 99999;"></div>
</body>
</html>
