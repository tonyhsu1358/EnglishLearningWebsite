<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MatchingGame.aspx.cs" Inherits="MatchingGame" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Matching Game</title>
    <style>
        /* ==================== 全局設定 ==================== */
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
        }

        /* 背景圖鋪滿 */
        body {
            background: url("images/SurfUpBackground.jpg") no-repeat center center fixed;
            background-size: cover;
        }

        /* ==================== 導覽列 ==================== */
        #navbar {
            background: rgba(255, 255, 255, 0);
            padding: 8px 20px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            z-index: 100;
        }

        /* 鑽石數量樣式 */
        .resource {
            font-weight: bold;
            font-family: "Segoe UI", "Microsoft JhengHei", Arial, sans-serif; /* ✅ 強制字型 */
            font-size: 18px;
            background: rgba(255, 255, 255, 0.6);
            padding: 4px 10px;
            border-radius: 8px;
            color: #000;
            display: flex;
            align-items: center;
            margin-right: 150px;
            gap: 5px;
            z-index: 100;
        }

        /* ==================== PANEL：外層容器 ==================== */
        .panel-container {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* ==================== PANEL：挑戰卡片 ==================== */
        .panel-card {
            width: 100%;
            max-width: 450px;
            background: linear-gradient(145deg, #f7f7f7, #eaeaea);
            border: 5px solid #4a90e2; /* ✅ 新增明顯的邊框 */
            border-radius: 20px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
            padding: 30px;
            text-align: center;
            font-family: "Segoe UI", sans-serif;
        }

        /* 標題 */
        .challenge-title {
            font-size: 1.8rem;
            margin-bottom: 10px;
            color: #3b3b3b;
        }

        /* 描述文字 */
        .challenge-description {
            font-size: 1rem;
            margin-bottom: 25px;
            color: #555;
        }

        /* 表單群組 */
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

            /* 表單標籤 */
            .form-group label {
                display: block;
                font-weight: bold;
                margin-bottom: 5px;
                color: #444;
            }

            /* 下拉選單 */
            .form-group select {
                width: 100%;
                padding: 10px;
                border-radius: 8px;
                border: 1px solid #ccc;
                font-size: 1rem;
            }

        /* 鑽石與賠率資訊 */
        .diamond-info {
            margin: 25px 0;
            color: #a94442;
            font-weight: bold;
        }

        /* 開始挑戰按鈕 */
        .start-btn {
            background-color: #4a90e2; /* 與 Panel 邊框一致的藍色 */
            color: #fff;
            font-size: 1.2rem;
            font-weight: bold;
            padding: 12px 30px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease; /* 平滑動畫 */
        }

            /* Hover 效果（提亮 + 放大） */
            .start-btn:hover {
                background-color: #66aef5; /* 比原本更亮的藍色 */
                transform: scale(1.05); /* 放大 1.05 倍 */
            }

            /* 按下 (Active) 效果（微縮 + 深色） */
            .start-btn:active {
                background-color: #3a78c2; /* 稍微深藍，模擬壓下去 */
                transform: scale(0.98); /* 微縮，像真實按鈕 */
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
            }

        /* 自訂下注輸入框 */
        .custom-bet {
            width: 100%;
            padding: 8px;
            border-radius: 8px;
            border: 1px solid #ccc;
            margin-top: 8px;
            font-size: 1rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- 導覽列 -->
        <div id="navbar">
            <span class="resource">
                <img src="images/diamond.svg" alt="魔法鑽石"
                    style="width: 24px; height: 24px; vertical-align: middle;" />
                <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
            </span>
        </div>

        <!-- ==================== PANEL：挑戰模式 ==================== -->
        <asp:Panel ID="pnlChallenge" runat="server" CssClass="panel-container">
            <div class="panel-card">
                <h2 class="challenge-title">🎯 連連看挑戰</h2>
                <p class="challenge-description">
                    請選擇下注鑽石數量、難度與時間後開始挑戰！成功將獲得額外鑽石獎勵！
                </p>

                <!-- 下注金額選擇 -->
                <div class="form-group">
                    <label for="bet">下注鑽石數量：</label>
                    <select id="bet">
                        <option value="1">1 顆</option>
                        <option value="10">10 顆</option>
                        <option value="50">50 顆</option>
                        <option value="100">100 顆</option>
                        <option value="custom">自訂</option>
                    </select>
                    <!-- ✅ placeholder 也改成 ≤100 -->
                    <input type="number" id="customBet" class="custom-bet" placeholder="輸入自訂金額 (≤100)" style="display: none;" />
                </div>

                <!-- 難度選擇 -->
                <div class="form-group">
                    <label for="difficulty">選擇難度：</label>
                    <select id="difficulty">
                        <option value="1.1">初級 (x1.1)</option>
                        <option value="1.2">中級 (x1.2)</option>
                        <option value="1.3">中高級 (x1.3)</option>
                    </select>
                </div>

                <!-- 時間選擇 -->
                <div class="form-group">
                    <label for="duration">挑戰時間：</label>
                    <select id="duration">
                        <option value="1.1">60 秒 (x1.1)</option>
                        <option value="1.2">40 秒 (x1.2)</option>
                        <option value="1.3">30 秒 (x1.3)</option>
                        <option value="1.4">20 秒 (x1.4)</option>
                        <option value="1.5">15 秒 (x1.5)</option>
                    </select>
                </div>

                <!-- 動態資訊 -->
                <div class="diamond-info">
                    <p id="rateInfo">賠率試算：x1.21</p>
                    <p id="rewardInfo">勝利後可得：0 顆鑽石(答對率高於90%才算勝利喔)</p>
                </div>

                <!-- 開始挑戰按鈕 -->
                <button type="button" class="start-btn" onclick="startChallenge()">開始挑戰</button>
            </div>
        </asp:Panel>
    </form>

    <script>

        /* 更新賠率與獎勵 */
        function updateRate() {
            let bet = document.getElementById("bet").value;
            let customBetInput = document.getElementById("customBet");
            let betAmount = parseInt(bet);

            if (bet === "custom") {
                customBetInput.style.display = "block";
                betAmount = parseInt(customBetInput.value) || 0;
            } else {
                customBetInput.style.display = "none";
            }

            // ✅ 限制最大只能 100
            if (betAmount > 100) betAmount = 100;

            let difficulty = parseFloat(document.getElementById("difficulty").value);
            let duration = parseFloat(document.getElementById("duration").value);

            let rate = 1.0 * difficulty * duration;
            let reward = Math.floor(betAmount * rate);

            document.getElementById("rateInfo").innerText = "賠率試算：x" + rate.toFixed(2);
            document.getElementById("rewardInfo").innerText = "勝利後可得：" + reward + " 顆鑽石";
        }

        /* 綁定事件 */
        document.getElementById("bet").addEventListener("change", updateRate);
        document.getElementById("customBet").addEventListener("input", updateRate);
        document.getElementById("difficulty").addEventListener("change", updateRate);
        document.getElementById("duration").addEventListener("change", updateRate);

        /* 按下開始挑戰 */
        function startChallenge() {
            alert("開始挑戰！後端將檢查鑽石是否足夠並進行扣款。");
        }
    </script>
</body>
</html>
