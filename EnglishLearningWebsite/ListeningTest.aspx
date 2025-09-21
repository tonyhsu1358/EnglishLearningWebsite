<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ListeningTest.aspx.cs" Inherits="ListeningTest" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>聽力測驗</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        /** 導覽列 **/
        #navbar {
            background: rgba(255, 255, 255, 0.8);
            padding: 8px 20px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            border-bottom: 2px solid #6b4226;
            z-index: 100;
        }

        /** 鑽石數量樣式 **/
        .resource {
            margin-right: 150px; /* 控制靠左或靠右 */
            font-weight: bold;
            font-size: 18px;
            background: rgba(255, 255, 255, 0.6);
            padding: 4px 10px;
            border-radius: 8px;
            color: #000;
            display: flex;
            align-items: center;
            gap: 5px;
            z-index: 100;
        }

        /** 外層遮罩 **/
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(252, 244, 228, 1) !important; /* 淡米色背景 */
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10;
        }

        /** ASP.NET Panel：承載內容 **/
        .panel-container {
            background: #fff;
            padding: 15px;
            border-radius: 15px;
            max-width: 800px;
            width: 80%;
            max-height: 80vh; /* 限制面板最高不要超過螢幕 */
            margin: auto;
            margin-top: 50px; /* 避開導覽列 */
            box-shadow: 0 8px 20px rgba(0,0,0,0.25);
            border: 5px solid #6b4226;
            overflow-y: auto; /* 超出時可滾動 */
        }

        /** 返回鍵樣式 **/
        .back-icon {
            width: 32px; /* 跟 info-icon 一樣大小 */
            height: 32px;
            cursor: pointer;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

            .back-icon:hover {
                transform: scale(1.2); /* hover 時放大 */
                filter: brightness(1.2); /* hover 時變亮 */
            }

        /** 顯示資訊圖標 **/
        .info-icon {
            width: 32px; /* 調整圖標大小 */
            height: 32px;
            cursor: pointer;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

            .info-icon:hover {
                transform: scale(1.2); /* 放大效果 */
                filter: brightness(1.2); /* 變亮 */
            }

        /* 題數下拉標籤美化 */
        label[for="ddlQuestionCount"] {
            font-weight: bold; /* 粗體 */
            color: #6b4226; /* 深咖啡色 */
            font-size: 15px; /* 與全選文字一致 */
        }

        /** 主題卡片 **/
        .topic-card {
            cursor: pointer;
            transition: transform 0.3s ease;
            height: 100%;
            font-size: 14px; /* 縮小字體 */
        }

            .topic-card:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 12px rgba(0,0,0,0.25);
            }

            .topic-card img {
                width: 100%;
                aspect-ratio: 5 / 4; /* 固定比例為 5:4 */
                object-fit: cover; /* 填滿卡片，不留白 */
                border-radius: 12px 12px 0 0;
            }

        .question-count {
            font-size: 13px;
            font-weight: bold;
            color: #6b4226;
            margin-left: 10px; /* ✅ 您可以自己手動調整這個值 */
        }

        .topic-card-body {
            padding: 12px;
            text-align: center;
        }

        /** 修正 Bootstrap row 邊距 **/
        #topicContainer {
            margin-left: 0 !important;
            margin-right: 0 !important;
        }

        /* 隱藏卡片內真正的原始 checkbox */
        .topicCheck {
            display: none !important;
        }

        .card-footer {
            padding: 4px 8px; /* ✅ 讓內容不會太緊 */
        }
        /* 卡片底部的自製勾選 BOX */
        .check-box {
            width: 24px;
            height: 24px;
            border: 2px solid #6b4226;
            border-radius: 4px;
            margin-left: 70px; /* ✅ 改這裡就能把勾選框往右推 */
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            background-color: #fff;
            transition: background-color 0.2s ease, transform 0.2s ease;
        }

            /* 勾選狀態 → 改用 SVG 畫勾 */
            .check-box.checked {
                background-color: #6b4226; /* 深咖啡底色 */
                border-color: #6b4226;
                transform: scale(1.1);
                background-image: url("images/tick.svg"); /* ✅ 載入您的白色勾勾 */
                background-repeat: no-repeat;
                background-position: center;
                background-size: 25px 25px;
            }

        /* 題數下拉美化 */
        .form-select {
            border: 2px solid #6b4226; /* 深咖啡邊框 */
            border-radius: 8px;
            padding: 6px 12px;
            font-size: 15px;
            font-weight: bold;
            color: #6b4226; /* 咖啡色文字 */
            background-color: #fdfaf6; /* 淡米色底 */
            transition: all 0.2s ease-in-out;
        }

            .form-select:focus {
                border-color: #8b5a2b; /* 聚焦時更深 */
                box-shadow: 0 0 6px rgba(107,66,38,0.5);
                outline: none;
            }

        /* 全選 checkbox 外層容器 */
        .form-check {
            display: flex;
            justify-content: center; /* 水平置中 */
            align-items: center; /* 垂直置中 */
            gap: 8px;
            font-size: 18px;
            font-weight: bold;
            color: #6b4226;
        }

        /* 全選標籤文字 */
        .form-check-label {
            font-size: 18px; /* ✅ 放大字體 */
            font-weight: bold; /* ✅ 粗體 */
            color: #6b4226; /* ✅ 深咖啡色 */
        }

        /* 全選 checkbox 本體 */
        .form-check-input[type=checkbox] {
            appearance: none !important;
            -webkit-appearance: none !important;
            -moz-appearance: none !important;
            width: 22px;
            height: 22px;
            border: 2px solid #6b4226;
            border-radius: 6px;
            cursor: pointer;
            background: #fff !important; /* 🚩 必加 !important，蓋掉 Bootstrap */
            background-image: none !important;
            transition: transform 0.2s ease, background-color 0.2s ease;
        }

            .form-check-input[type=checkbox]:hover {
                transform: scale(1.1); /* hover 時微放大 */
            }

            .form-check-input[type=checkbox]:checked {
                background-color: #6b4226 !important;
                border-color: #6b4226 !important;
                background-image: url("images/tick.svg") !important; /* 🚩 必加 !important */
                background-repeat: no-repeat;
                background-position: center;
                background-size: 16px 16px;
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- 🔹 導覽列 -->
        <div id="navbar">
            <span class="resource">
                <img src="images/diamond.svg" alt="魔法鑽石"
                    style="width: 24px; height: 24px; vertical-align: middle;" />
                <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
            </span>
        </div>

        <div class="overlay">
            <asp:Panel ID="pnlListeningMenu" runat="server" CssClass="panel-container">
                <!-- 標題 -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <asp:ImageButton ID="btnBack" runat="server" ImageUrl="~/images/back-arrow.svg"
                        CssClass="me-3 back-icon" OnClick="btnBack_Click" AlternateText="返回" />
                    <h3 class="flex-grow-1 text-center">🎧 請選擇聽力測驗主題</h3>
                    <button type="button" class="btn btn-light info-btn" data-bs-toggle="modal" data-bs-target="#infoModal">
                        <img src="images/info-icon.svg" alt="資訊" class="info-icon" />
                    </button>
                </div>

                <!-- 題數下拉 -->
                <div class="text-center mb-3">
                    <label for="ddlQuestionCount" class="form-label me-2">選擇題目數量：</label>
                    <asp:DropDownList ID="ddlQuestionCount" runat="server" CssClass="form-select d-inline-block" Width="150px">
                        <asp:ListItem Value="5">5 題</asp:ListItem>
                        <asp:ListItem Value="10" Selected="True">10 題</asp:ListItem>
                        <asp:ListItem Value="15">15 題</asp:ListItem>
                        <asp:ListItem Value="20">20 題</asp:ListItem>
                        <asp:ListItem Value="25">25 題</asp:ListItem>
                        <asp:ListItem Value="30">30 題</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <!-- 全選 -->
                <div class="text-center mb-3" onclick="toggleAll()">
                    <div class="form-check d-inline-flex align-items-center justify-content-center" style="cursor: pointer;">
                        <div class="check-box me-2" id="chkAllBox"></div>
                        <label for="chkAll" class="form-check-label mb-0">全選所有主題</label>
                        <input type="checkbox" id="chkAll" class="d-none" />
                    </div>
                </div>

                <!-- 主題卡片區 -->
                <div class="row" id="topicContainer">
                    <asp:Repeater ID="rptTopics" runat="server">
                        <ItemTemplate>
                            <div class="col-md-4 mb-4">
                                <div class="card topic-card" onclick="toggleCheckBox('<%# Eval("TopicID") %>')">
                                    <img src='<%# Eval("ImagePath") %>' alt='<%# Eval("TopicName") %>' />
                                    <div class="topic-card-body">
                                        <h5><%# Eval("TopicName") %></h5>
                                        <p><%# Eval("Description") %></p>

                                        <!-- ✅ 改成純 HTML input，確保 JS 可正確存取 -->
                                        <input type="checkbox"
                                            name="selectedTopics"
                                            class="d-none topicCheck"
                                            value='<%# Eval("TopicID") %>' />

                                        <!-- ✅ 勾選框 + 題數 -->
                                        <div class="card-footer d-flex align-items-center">
                                            <div class="check-box" data-topicid='<%# Eval("TopicID") %>'></div>
                                            <span class="question-count">
                                                <%# (Eval("TopicName").ToString() == "多益測驗") ? "題數：100 題" : "題數：10 題" %>
                                            </span>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="text-center mt-3">
                    <asp:Button ID="btnStart" runat="server" Text="開始測驗" CssClass="btn btn-primary" OnClick="btnStart_Click" />
                </div>
            </asp:Panel>
        </div>
    </form>

    <!-- Info Modal -->
    <div class="modal fade" id="infoModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">玩法說明</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    在這裡您可以選擇題數與主題，系統將依照選擇自動生成測驗。
                </div>
            </div>
        </div>
    </div>

    <script>
        // 點擊卡片切換
        function toggleCheckBox(topicId) {
            let cb = document.querySelector(".topicCheck[value='" + topicId + "']"); // ✅ 現在能正確找到 input
            if (!cb) return;

            cb.checked = !cb.checked;

            let box = document.querySelector(".check-box[data-topicid='" + topicId + "']");
            if (box) box.classList.toggle("checked", cb.checked);
        }

        // 全選/取消全選
        function toggleAll() {
            let cb = document.getElementById("chkAll");
            cb.checked = !cb.checked;

            // 切換外觀
            let box = document.getElementById("chkAllBox");
            box.classList.toggle("checked", cb.checked);

            // 同步所有卡片
            document.querySelectorAll(".topicCheck").forEach(c => {
                c.checked = cb.checked;
                let b = document.querySelector(".check-box[data-topicid='" + c.value + "']");
                if (b) b.classList.toggle("checked", cb.checked);
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
