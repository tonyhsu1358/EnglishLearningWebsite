<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AISelectionResult.aspx.cs" Inherits="AISelectionResult" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>測驗結果</title>

    <!-- ✅ Bootstrap 5 & FontAwesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />

    <style>
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(to right, #F5F5F5, #C9CCD5);
            background-size: cover; /* ✅ 讓背景圖片填滿畫面 */
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .container {
            max-width: 900px;
            background: #FAF3E0; /* 莫蘭迪淡米色 */
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        h2 {
            color: #6D5F57; /* 莫蘭迪深棕色 */
            font-weight: bold;
        }

        /* 🎉 獎勵訊息 (更有遊戲感) */
        #rewardMessage {
            background: linear-gradient(to right, #FFD700, #FFC107); /* 金黃色漸層 */
            color: #5A3E09; /* 深金色 */
            font-size: 24px; /* 放大字體 */
            font-weight: bold;
            padding: 18px;
            border-radius: 12px; /* 圓角 */
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.2); /* 增加立體陰影 */
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            border: 3px solid #D4AF37; /* 金色邊框 */
            text-shadow: 1px 1px 5px rgba(255, 255, 255, 0.7);
            animation: fadeIn 0.8s ease-in-out;
        }

        /* 🔹 鑽石數量數字 (特別放大 + 動畫) */
        #diamondCount {
            font-size: 28px; /* 更大 */
            font-weight: bold;
            color: #C82333; /* 紅色強調 */
            animation: bounce 1s infinite alternate;
        }

        /* 🎉 Emoji 也放大 */
        #rewardMessage i {
            font-size: 30px;
        }

        /* ✅ 進場動畫 */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.8);
            }

            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        /* ✅ 鑽石數量動態效果 */
        @keyframes bounce {
            from {
                transform: translateY(0);
            }

            to {
                transform: translateY(-5px);
            }
        }

        .gridview-container {
            margin-top: 20px;
        }
        /* ✅ 讓 GridView 內的文字置中對齊 */
        .table-bordered td, .table-bordered th {
            vertical-align: middle !important; /* 文字垂直置中 */
            text-align: center; /* 文字水平置中 */
        }

        .correct-answer {
            background-color: #C5E1A5 !important; /* 莫蘭迪綠 */
            color: #2E7D32 !important;
            font-weight: bold;
        }

        .wrong-answer {
            background-color: #F5C6CB !important; /* 莫蘭迪粉紅 */
            color: #C82333 !important;
            font-weight: bold;
        }

        .question-text {
            font-weight: bold;
            color: #333;
        }

        .result-summary {
            font-size: 18px;
            font-weight: bold;
            color: #6D5F57;
            margin-top: 15px;
        }

        .level-container {
            text-align: center;
            margin-top: 30px;
        }

        /* ✅ 確保按鈕顏色與背景對比明顯 */
        .btn-level {
            color: white !important; /* ✅ 強制按鈕文字為白色 */
            font-size: 18px;
            font-weight: bold;
            padding: 12px 20px;
            border-radius: 25px;
            border: none;
            transition: all 0.3s ease-in-out;
            text-decoration: none;
            display: inline-block;
        }

        /* ✅ 不同等級按鈕顏色 */
        .level-1 {
            background: #B0A8B9;
        }

        .level-2 {
            background: #9E9B9B;
        }

        .level-3 {
            background: #C3BEB6;
            color: black;
        }

        .level-4 {
            background: #8B9A88;
        }

        .level-5 {
            background: #A89F91;
        }

        .level-6 {
            background: #9093A0;
        }


        /* ✅ 為不同等級的按鈕設定不同的 hover 顏色 */
        .level-1:hover {
            background: #9182A6 !important;
            transform: translateY(-3px);
        }
        /* A1 深灰紫 */
        .level-2:hover {
            background: #7D7B7B !important;
            transform: translateY(-3px);
        }
        /* A2 深灰 */
        .level-3:hover {
            background: #A89D94 !important;
            transform: translateY(-3px);
        }
        /* B1 深米色 */
        .level-4:hover {
            background: #6F8470 !important;
            transform: translateY(-3px);
        }
        /* B2 深綠 */
        .level-5:hover {
            background: #8B7D6F !important;
            transform: translateY(-3px);
        }
        /* C1 深棕 */
        .level-6:hover {
            background: #6B7380 !important;
            transform: translateY(-3px);
        }
        /* C2 深藍灰 */

        .reward-container {
            margin-top: 15px;
        }

        /* ✅ 預設的鑽石訊息樣式 */
        .diamond-label {
            font-size: 22px;
            font-weight: bold;
            color: #0056b3; /* 預設藍色 */
            padding: 12px 18px;
            display: block;
            border-radius: 10px;
            text-align: center;
        }

            /* 🎉 成功獲得鑽石（用綠色） */
            .diamond-label.success {
                background: linear-gradient(to right, #28a745, #218838); /* 綠色漸層 */
                color: white;
                border: 2px solid #1e7e34;
                box-shadow: 0px 5px 10px rgba(0, 128, 0, 0.2);
            }

            /* ⚠ 已領取過獎勵（用黃色警告） */
            .diamond-label.warning {
                background: linear-gradient(to right, #FFD700, #FFC107); /* 金黃色漸層 */
                color: #5A3E09;
                border: 2px solid #D4AF37;
                box-shadow: 0px 5px 10px rgba(255, 193, 7, 0.2);
            }
        /* 🎨 美化 Bootstrap Tooltip */
        .tooltip-inner {
            background: linear-gradient(to right, #FFD700, #FFC107); /* 金黃色漸層 */
            color: #5A3E09; /* 深金色 */
            font-size: 16px; /* 讓字體大一點 */
            font-weight: bold;
            border-radius: 8px; /* 圓角 */
            padding: 10px 15px; /* 內距 */
            text-align: center;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.2); /* 增加立體感 */
        }

        /* 🔹 Tooltip 箭頭顏色 */
        .bs-tooltip-top .tooltip-arrow::before {
            border-top-color: #FFD700 !important;
        }

        .bs-tooltip-bottom .tooltip-arrow::before {
            border-bottom-color: #FFD700 !important;
        }

        .bs-tooltip-start .tooltip-arrow::before {
            border-left-color: #FFD700 !important;
        }

        .bs-tooltip-end .tooltip-arrow::before {
            border-right-color: #FFD700 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2><i class="fa-solid fa-list-check"></i>測驗結果</h2>

            <!-- 🎉 ✅ 顯示獲得鑽石 (美化後) -->
            <div id="rewardMessage" class="text-center" role="alert" style="display: none;">
                <i class="fa-solid fa-gem"></i>恭喜！你獲得了 <span id="diamondCount"></span>顆鑽石 🎉
            </div>


            <!-- ✅ 測驗結果統計 -->
            <div class="result-summary">
                <asp:Label ID="lblScoreSummary" runat="server"></asp:Label>
            </div>

            <!-- ✅ 新增 Label 顯示鑽石數量 -->
            <div class="reward-container">
                <asp:Label ID="lblDiamonds" runat="server" CssClass="diamond-label"></asp:Label>
            </div>

            <!-- ✅ GridView 顯示使用者的作答結果 -->
            <div class="gridview-container">
                <asp:GridView ID="gvUserResults" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered">
                    <Columns>
                        <asp:BoundField DataField="QuestionText" HeaderText="題目" ItemStyle-CssClass="question-text" />
                        <asp:BoundField DataField="SelectedAnswerFull" HeaderText="你的答案" />
                        <asp:BoundField DataField="CorrectAnswerFull" HeaderText="正確答案" />
                        <asp:TemplateField HeaderText="結果">
                            <ItemTemplate>
                                <asp:Label ID="lblResult" runat="server"
                                    Text='<%# Eval("IsCorrect").ToString() == "True" ? "✔ 正確" : "✖ 錯誤" %>'
                                    CssClass='<%# Eval("IsCorrect").ToString() == "True" ? "correct-answer" : "wrong-answer" %>'>
                                </asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ✅ 按鈕顯示適合的 CEFR & TOEIC 等級 -->
            <div class="level-container">
                <h3>根據你的表現，推薦你挑戰：</h3>
                <!-- ✅ CEFR 按鈕（Tooltip 由後端動態設定） -->
                <asp:HyperLink ID="hlVocabularyGame" runat="server" CssClass="btn btn-level"></asp:HyperLink>
            </div>

        </div>
    </form>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // ✅ 先確保 Tooltip 作用在正確的元素上
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));

        if (tooltipTriggerList.length === 0) {
            console.warn("⚠ Tooltip 未正確設定，請檢查 HTML 結構！");
        }

        // ✅ 初始化 Bootstrap Tooltip
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl, {
                container: 'body', // 避免 Tooltip 跑版
                placement: 'top', // 設定出現位置
                delay: { "show": 200, "hide": 100 }, // 增加顯示延遲，避免跳動
            });
        });

        // ✅ 手動觸發 Tooltip（防止不顯示）
        var vocabGameButton = document.getElementById("hlVocabularyGame");
        if (vocabGameButton) {
            vocabGameButton.addEventListener("mouseenter", function () {
                var tooltipInstance = bootstrap.Tooltip.getInstance(vocabGameButton);
                if (tooltipInstance) {
                    tooltipInstance.show();
                }
            });

            vocabGameButton.addEventListener("mouseleave", function () {
                var tooltipInstance = bootstrap.Tooltip.getInstance(vocabGameButton);
                if (tooltipInstance) {
                    tooltipInstance.hide();
                }
            });
        } else {
            console.error("❌ 找不到 `hlVocabularyGame` 按鈕！");
        }
    });
</script>
</body>
</html>
