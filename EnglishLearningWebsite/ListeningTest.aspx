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
            margin: 0 10px;
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

        /** 外層遮罩：讓內部面板置中，並套用淡米色半透明背景 **/
        .overlay {
            position: fixed;
            top: 0; /* ⬅ 從導覽列高度之後開始 */
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(252, 244, 228, 1) !important; /* 🔹 淡米色遮罩 */
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10;
        }

        /** 內層面板容器：承載整個內容，含標題/題數/主題卡片 **/
        .panel-container {
            background: #fff;
            padding: 15px;
            border-radius: 15px;
            max-width: 800px; /* 固定最大寬度 */
            width: 80%;
            margin: auto; /* 置中 */
            margin-top: 70px; /* ⬅ 騰出導覽列的高度，避免被擋住 */
            box-shadow: 0 8px 20px rgba(0,0,0,0.25);
            border: 5px solid #6b4226; /* 咖啡色邊框 */
        }

        /** 主題卡片的整體效果：帶有 hover 放大動畫 **/
        .topic-card {
            cursor: pointer;
            transition: transform 0.3s ease;
            height: 100%; /* 🔹 撐滿父容器，避免高度不一致 */
        }

            /** 滑鼠移到主題卡片時：放大+陰影 **/
            .topic-card:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 12px rgba(0,0,0,0.25);
            }

            /** 主題卡片內的圖片樣式：完整顯示圖片，不裁切，固定高度 **/
            .topic-card img {
                width: 100%;
                height: 200px; /* 🔹 固定高度確保整齊 */
                object-fit: contain; /* 🔹 確保圖片完整顯示，不裁切 */
                background-color: #fff; /* 🔹 背景填白，避免圖片比例不同造成空白 */
                border-radius: 12px 12px 0 0;
            }

        /** 卡片內文字區塊，置中顯示 **/
        .topic-card-body {
            padding: 12px;
            text-align: center;
        }

        /** 修正 Bootstrap 預設 row 造成超出邊界的問題 **/
        #topicContainer {
            margin-left: 0 !important;
            margin-right: 0 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- 🔹 導覽列 (顯示鑽石數量) -->
        <div id="navbar">
            <span class="resource">
                <img src="images/diamond.svg" alt="魔法鑽石"
                    style="width: 24px; height: 24px; vertical-align: middle;" />
                <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
            </span>
        </div>

        <div class="overlay">
            <div class="panel-container">
                <!-- 標題與返回 -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <asp:ImageButton ID="btnBack" runat="server" ImageUrl="~/images/back-arrow.svg"
                        CssClass="me-3" Width="30" Height="30" OnClick="btnBack_Click" />
                    <h3 class="flex-grow-1 text-center">🎧 請選擇聽力測驗主題</h3>
                    <button type="button" class="btn btn-light" data-bs-toggle="modal" data-bs-target="#infoModal">
                        <i class="bi bi-info-circle"></i>
                    </button>
                </div>

                <!-- 題數下拉選單 -->
                <div class="mb-3">
                    <label for="ddlQuestionCount" class="form-label">選擇題目數量：</label>
                    <asp:DropDownList ID="ddlQuestionCount" runat="server" CssClass="form-select" Width="200px">
                        <asp:ListItem Value="5">5 題</asp:ListItem>
                        <asp:ListItem Value="10" Selected="True">10 題</asp:ListItem>
                        <asp:ListItem Value="15">15 題</asp:ListItem>
                        <asp:ListItem Value="20">20 題</asp:ListItem>
                        <asp:ListItem Value="25">25 題</asp:ListItem>
                        <asp:ListItem Value="30">30 題</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <!-- 全選 -->
                <div class="form-check mb-3">
                    <input type="checkbox" class="form-check-input" id="chkAll" onclick="toggleAll()" />
                    <label for="chkAll" class="form-check-label">全選所有主題</label>
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
                                        <asp:CheckBox ID="chkTopic" runat="server" CssClass="d-none topicCheck"
                                            InputAttributes-Value='<%# Eval("TopicID") %>' />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="text-center mt-3">
                    <asp:Button ID="btnStart" runat="server" Text="開始測驗" CssClass="btn btn-primary" OnClick="btnStart_Click" />
                </div>
            </div>
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
        // 全選/取消全選所有主題
        function toggleAll() {
            let isChecked = document.getElementById("chkAll").checked;
            document.querySelectorAll(".topicCheck input").forEach(cb => cb.checked = isChecked);
        }

        // 點擊卡片時切換勾選狀態
        function toggleCheckBox(topicId) {
            let cb = document.querySelector(".topicCheck input[value='" + topicId + "']");
            cb.checked = !cb.checked;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
