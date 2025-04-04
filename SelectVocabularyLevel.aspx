<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SelectVocabularyLevel.aspx.cs" Inherits="SelectVocabularyLevel" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>選擇單字等級 | English Learning</title>

    <!-- Bootstrap 5 & FontAwesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />

    <style>
        /* ✅ 設定背景圖片 */
        body {
            font-family: 'Arial', sans-serif;
            background: url('images/SelectVocabularyLevelBackground.jpg') no-repeat center center fixed;
            background-size: cover;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* ✅ 主要內容容器 */
        .container {
            max-width: 800px;
            padding: 30px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            text-align: center;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.2);
            position: relative;
            z-index: 1;
        }

        /* ✅ 修正標題區域，讓圖標與標題正確對齊 */
        .header-container {
            display: flex;
            align-items: center; /* ⬅️ 讓 AI 圖標、標題、資訊圖標保持水平對齊 */
            justify-content: center; /* ⬅️ 水平置中 */
            gap: 10px; /* ⬅️ 增加間距，避免圖標與標題擠在一起 */
            margin-bottom: 25px; /* ⬅️ 增加標題與按鈕的距離 */
            position: relative;
        }

        h2 {
            flex-basis: 100%; /* ⬅️ 讓標題單獨一行，避免與圖標擠在同一列 */
            text-align: center;
            margin-top: 10px; /* ⬅️ 增加標題與圖標的距離 */
        }

        /* ✅ 調整圖標區域，讓它們與標題同行 */
        .icon-container {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* ✅ 莫蘭迪色調按鈕 */
        .level-button {
            display: block;
            width: 100%;
            padding: 15px;
            border: none;
            font-size: 18px;
            font-weight: bold;
            color: white;
            border-radius: 15px;
            margin: 10px 0;
            transition: all 0.3s ease-in-out;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            text-transform: uppercase;
        }

        /* ✅ 莫蘭迪色系 */
        .level-1 {
            background: #B0A8B9;
        }
        /* 淺灰 */
        .level-2 {
            background: #9E9B9B;
        }
        /* 暖灰 */
        .level-3 {
            background: #C3BEB6;
        }
        /* 米色 */
        .level-4 {
            background: #8B9A88;
        }
        /* 橄欖綠 */
        .level-5 {
            background: #A89F91;
        }
        /* 淡棕色 */
        .level-6 {
            background: #9093A0;
        }
        /* 冷灰藍 */
        .level-7 {
            background: #8D7E77;
        }
        /* 灰咖啡色 */

        /* ✅ 按鈕 Hover 效果 */
        .level-button:hover {
            transform: translateY(-3px);
            filter: brightness(1.15);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
        }

        /* ✅ AI & 資訊 ICON 容器 */
        .icon-container {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 100%;
            display: flex;
            justify-content: space-between;
            padding: 0 20px;
        }

        /* ✅ AI 機器人 SVG 圖標 */
        .ai-icon {
            width: 41px;
            height: 41px;
            cursor: pointer;
            transition: 0.3s;
            filter: brightness(0) saturate(100%) invert(18%) sepia(94%) saturate(2104%) hue-rotate(201deg) brightness(97%) contrast(90%);
            position: relative;
        }

            .ai-icon:hover {
                transform: scale(1.1);
                filter: brightness(0) saturate(100%) invert(35%) sepia(99%) saturate(784%) hue-rotate(201deg) brightness(95%) contrast(94%);
            }

        /* ✅ 資訊圖標 */
        .info-icon {
            font-size: 39px;
            cursor: pointer;
            color: #555;
            transition: 0.3s;
            margin-left: auto;
            transition: transform 0.3s ease-in-out;
        }

            .info-icon:hover {
                color: #333;
                transform: scale(1.1); /* ⬅️ 增加放大效果 */
            }

        .tooltip-container {
            position: relative; /* ✅ 確保 Tooltip 正確定位 */
            display: inline-block;
            cursor: pointer;
        }

        .modal-dialog {
            max-width: 500px; /* ✅ 設定適當寬度，不要過大 */
        }

        .modal-body {
            max-height: 400px; /* ✅ 限制最大高度，讓內容不超過視窗 */
            overflow-y: auto; /* ✅ 當內容過長時，允許內部捲動 */
        }

        /* ✅ 原本的莫蘭迪按鈕 */
        .btn-primary {
            background: linear-gradient(135deg, #A89F91, #8D7E77); /* ✅ 莫蘭迪暖灰色調 */
            color: white;
            border: none;
            font-size: 18px;
            font-weight: bold;
            padding: 12px 24px;
            border-radius: 25px;
            transition: all 0.3s ease-in-out;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            z-index: 1;
        }

        .home-button {
            width: 200px;
            max-width: 100%;
            margin: 0 auto; /* ✅ 讓它置中 */
        }
        /* ✅ 你的 Hover 效果 —— 有！保留著！*/
        .btn-primary:hover:not(.home-button) {
            background: linear-gradient(135deg, #8D7E77, #756B63); /* ✅ 略深的莫蘭迪色 */
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.4);
        }

        /* ✅ 只有回首頁這顆按鈕 hover 會放大 */
        .home-button:hover {
            transform: scale(1.05);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.4);
        }

        /* ✅ 外層金色邊框 + 流動畫效果 */
        .glow-border {
            display: inline-block;
            padding: 3px; /* 邊框厚度 */
            border-radius: 30px;
            background: linear-gradient(270deg, gold, #ffcc00, #ffd700, gold); /* 金色漸層 */
            background-size: 600% 600%;
            animation: borderMove 5s linear infinite;
        }

            /* ✅ 包住的按鈕樣式保留 */
            .glow-border .btn-primary {
                border-radius: 25px;
                display: inline-block;
                z-index: 1;
                position: relative;
            }

        /* ✅ 邊框動畫 */
        @keyframes borderMove {
            0% {
                background-position: 0% 50%;
            }

            50% {
                background-position: 100% 50%;
            }

            100% {
                background-position: 0% 50%;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="header-container">
                <div class="tooltip-container" data-bs-toggle="tooltip" data-bs-placement="top" title="🔍 試試AI助手實力診斷！" onclick="window.location.href='AISelection.aspx'">
                    <img src="images/robot.svg" class="ai-icon" alt="AI 小助手" />
                </div>
                <h2 class="title">選擇你的學習等級</h2>
                <i class="fa-solid fa-circle-info info-icon"
                    id="infoIcon"
                    data-bs-toggle="tooltip"
                    data-bs-placement="top"
                    title="ℹ️ 點我查看詳細資訊"></i>
            </div>

            <!-- LEVEL 按鈕 -->
            <asp:Button ID="btnLevel1" runat="server" CssClass="level-button level-1" Text="晨曦林地" OnClick="btnLevel_Click" CommandArgument="1" />
            <asp:Button ID="btnLevel2" runat="server" CssClass="level-button level-2" Text="神秘林間" OnClick="btnLevel_Click" CommandArgument="2" />
            <asp:Button ID="btnLevel3" runat="server" CssClass="level-button level-3" Text="低語之谷" OnClick="btnLevel_Click" CommandArgument="3" />
            <asp:Button ID="btnLevel4" runat="server" CssClass="level-button level-4" Text="長老荒野" OnClick="btnLevel_Click" CommandArgument="4" />
            <asp:Button ID="btnLevel5" runat="server" CssClass="level-button level-5" Text="天穹密林" OnClick="btnLevel_Click" CommandArgument="5" />
            <asp:Button ID="btnLevel6" runat="server" CssClass="level-button level-6" Text="虛幻樹海" OnClick="btnLevel_Click" CommandArgument="6" />
            <asp:Button ID="btnLevel7" runat="server" CssClass="level-button level-7" Text="秘法之核" OnClick="btnLevel_Click" CommandArgument="7" />
        </div>
        <!-- ✅ 這裡是 .container 的結束 -->

        <!-- 🔹 ✅ **回首頁按鈕**，放在 <form> 結束標籤前 -->
        <div class="text-center mt-4">
            <div class="glow-border">
                <asp:Button ID="btnHome" runat="server" CssClass="btn btn-primary home-button px-4 py-2" Text="回首頁" OnClick="btnHome_Click" />
            </div>
        </div>

    </form>
    <!-- ✅ 確保這是 `</form>` 的正確結尾 -->

    <!-- 🔹 Bootstrap 5 Modal -->
    <div class="modal fade" id="infoModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <!-- ✅ 縮小對話框 -->
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">CEFR 等級對應多益分數</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <h4 class="text-primary"><i class="fa-solid fa-info-circle"></i>遊戲簡介</h4>
                    <p>
                        🌟 <b>English Learning</b> 是一款結合 <b>AI 分析</b> 與 <b>互動遊戲</b> 的英語學習平台！
                    透過單字測驗、聽力挑戰與趣味配對，提升你的英語能力 🎯
                    </p>

                    <h4 class="text-success"><i class="fa-solid fa-robot"></i>AI 診斷機制</h4>
                    <p>
                        🔍 <b>AI 智慧診斷</b> 會根據你的答題表現，<b>自動分析你的英語等級</b>，確保學習內容適合你的需求！
                    若不確定等級，點擊 <b>AI 小助手</b> 進行測驗吧！✨
                    </p>

                    <h4 class="text-warning"><i class="fa-solid fa-chart-line"></i>CEFR 等級與多益對應</h4>
                    <ul class="list-group">
                        <li class="list-group-item"><b>A1 初級：</b> 120-225 分 – 簡單英語表達，適合入門者 🟢</li>
                        <li class="list-group-item"><b>A2 初中級：</b> 225-550 分 – 能進行基本對話，適合基礎學習者 🟡</li>
                        <li class="list-group-item"><b>B1 中級：</b> 550-785 分 – 能應對一般情境，適合有基礎的學習者 🟠</li>
                        <li class="list-group-item"><b>B2 中高級：</b> 785-945 分 – 可流利交談，適合進階學習者 🔵</li>
                        <li class="list-group-item"><b>C1 高級：</b> 945-990 分 – 可應對複雜討論，適合專業人士 🔴</li>
                        <li class="list-group-item"><b>C2 精通級：</b> 母語水平，適合高階英語使用者 🟣</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>


    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- ✅ 啟用 Bootstrap 5 Tooltip -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });
    </script>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // ✅ 啟用 Bootstrap 5 Tooltip
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });

            // ✅ 讓點擊 ℹ️ 圖標時開啟 Modal
            document.getElementById("infoIcon").addEventListener("click", function () {
                var modal = new bootstrap.Modal(document.getElementById("infoModal"));
                modal.show();
            });
        });
    </script>

</body>
</html>
