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
            background: url('images/grassland1.svg') no-repeat center center fixed;
            background-size: cover;
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
            gap: 5px; /* 按鈕之間的距離 */
            width: 100%; /* 讓 Grid 佔滿 `.altar-container` */
            height: 100%; /* 讓 Grid 自適應高度，避免限制按鈕行距 */
            padding: 10px;
            box-sizing: border-box;
        }

        /* 🪨 初始狀態（未學習）*/
        .altar-button.locked {
            background: #a9a9a9; /* 石頭灰色 */
            color: #fff;
            border: 2px solid #555;
            box-shadow: inset 0 0 5px #333;
            border-radius: 10px;
        }

        /* 🌱 學習中狀態 */
        .altar-button.learning {
            background: linear-gradient(135deg, #b3d59c, #76b852); /* 淺綠 + 森林綠 */
            color: #fff;
            border: 2px solid #4e944f;
            box-shadow: 0 0 5px #76b852;
            animation: pulse 2s infinite;
            border-radius: 10px;
        }

        /* 🍂 乾枯狀態（提醒複習） */
        .altar-button.withered {
            background: linear-gradient(135deg, #c79857, #7e5f33); /* 褐色調 */
            color: #fffbe0;
            border: 2px dashed #5a3e1b;
            box-shadow: 0 0 5px rgba(255, 204, 0, 0.5);
            border-radius: 10px;
        }

        /* ✨ 完全狀態（完成） */
        .altar-button.completed {
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

        /* ❌ 右上角關閉按鈕 */
        .info-modal-close {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 22px;
            font-weight: bold;
            color: #333;
            cursor: pointer;
            transition: 0.3s;
        }

            .info-modal-close:hover {
                color: #e74c3c;
                transform: scale(1.2);
            }

        .magic-forest-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: #fff7e6;
            border: 3px solid #d2b48c;
            border-radius: 15px;
            padding: 30px;
            z-index: 9999;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.4);
            width: 400px;
            text-align: center;
        }

        .forest-panel-content h3 {
            font-weight: bold;
            margin-bottom: 20px;
        }

        .forest-close {
            position: absolute;
            top: 10px;
            right: 15px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            color: #444;
            font-size: 20px;
            font-weight: bold;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            transition: all 0.3s ease-in-out;
        }

            /* ✨ 滑鼠懸停時出現光暈效果 */
            .forest-close:hover {
                box-shadow: 0 0 12px rgba(255, 100, 100, 0.8); /* 紅色光暈，可自定顏色 */
                transform: scale(1.1);
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <!-- 🔹 狀態列 (從資料庫讀取) -->
            <div class="row">
                <div class="col-12" id="navbar">
                    <span class="resource">
                        <img src="images/energy.svg" alt="魔法能量" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <asp:Label ID="lblEnergy" runat="server"></asp:Label>
                    </span>
                    <span class="resource">
                        <img src="images/diamond.svg" alt="魔法鑽石" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <asp:Label ID="lblDiamonds" runat="server"></asp:Label>
                    </span>
                    <span class="resource">
                        <img id="volumeIcon" src="images/volume.svg" alt="背景音樂" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <input type="range" id="volumeSlider" min="0" max="1" step="0.01" value="0.5" title="調整音量" />
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
                        <asp:Panel ID="pnlMagicForest" runat="server" ClientIDMode="Static" CssClass="magic-forest-panel" Style="display: none;">
                            <div class="forest-panel-content">
                                <!-- 叉叉關閉 -->
                                <span class="forest-close" onclick="closeForestPanel()">&times;</span>
                                <!-- 面板標題 -->
                                <h3>森林功能面板</h3>
                                <!-- 切換森林按鈕 -->
                                <asp:Button ID="btnSwitchForest" runat="server"
                                    Text="切換森林"
                                    CssClass="btn btn-primary m-2"
                                    OnClientClick="stopBGM();"
                                    OnClick="btnSwitchForest_Click" />
                                <!-- 返回首頁按鈕 -->
                                <asp:Button ID="btnBackHome" runat="server" Text="返回首頁" CssClass="btn btn-secondary m-2" OnClick="btnBackHome_Click" />
                                <!-- 查看統計按鈕 -->
                                <asp:Button ID="btnViewStats" runat="server" Text="查看統計" CssClass="btn btn-info m-2" OnClick="btnViewStats_Click" />
                            </div>
                        </asp:Panel>

                        <!-- !-- ✅ 🔽 新增：祭壇儀表板 (永遠顯示在UI，每個LEVEL裡面都包含100顆按鈕) -->
                        <asp:Panel ID="pnlMagicAltar" runat="server" Visible="true" CssClass="altar-grid">
                            <asp:Literal ID="litAltarGrid" runat="server"></asp:Literal>
                        </asp:Panel>

                        <!-- ✅ 🔽 新增：祭壇選擇儀表板（點選祭壇按鈕後顯示） -->
                        <asp:Panel ID="pnlAltarOptions" runat="server" ClientIDMode="Static" CssClass="altar-options-panel" Style="display: none;">
                            <div class="altar-options-content">
                                <!-- 日後放「進入學習」「開始測驗」「關閉」等選項 -->
                            </div>
                        </asp:Panel>

                    </div>
                </div>
            </div>
        </div>
        <!-- 🔸 暫時用不到之後會大改古代卷軸面板（預設為隱藏，後端控制可見性） -->
        <div id="pnlAncientScroll" runat="server" visible="false">
            <!-- 🔹 用 asp:Literal 動態產生單字列表或其他內容 -->
            <asp:Literal ID="litWordList" runat="server"></asp:Literal>
            <!-- 🔹 關閉古代卷軸的按鈕，點擊後觸發後端 btnCloseWordList_Click 方法 -->
            <asp:Button ID="btnCloseWordList" runat="server" Text="關閉" OnClick="btnCloseWordList_Click" />
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
    <script>
        // 顯示森林儀表板
        function toggleForestPanel() {
            const panel = document.getElementById("<%= pnlMagicForest.ClientID %>");
            if (panel) {
                panel.style.display = "block";
            }
        }
        // 關閉森林儀表板
        function closeForestPanel() {
            const panel = document.getElementById("<%= pnlMagicForest.ClientID %>");
            if (panel) {
                panel.style.display = "none";
            }
        }
    </script>
    <audio id="bgm" src="musics/ScentOfForest.mp3" autoplay loop></audio>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const audio = document.getElementById("bgm");
            const volumeSlider = document.getElementById("volumeSlider");
            const volumeIcon = document.getElementById("volumeIcon");

            // 預設音量為 0.5
            audio.volume = 0.5;

            // 根據音量設定圖示
            function updateVolumeIcon(volume) {
                if (volume == 0) {
                    volumeIcon.src = "images/volume0.svg";
                } else {
                    volumeIcon.src = "images/volume.svg";
                }
            }
            // 初始化圖示
            updateVolumeIcon(audio.volume);

            // 當滑桿變動時
            volumeSlider.addEventListener("input", function () {
                const newVolume = parseFloat(this.value);
                audio.volume = newVolume;
                updateVolumeIcon(newVolume);
            });
        });
    </script>
    <script>
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
                audio.src = "";  // 關鍵：清掉音源，讓瀏覽器以為沒有聲音了
                audio.load();    // 強迫重新載入，觸發「音訊已停止」
            }
        }
    </script>
</body>
</html>
