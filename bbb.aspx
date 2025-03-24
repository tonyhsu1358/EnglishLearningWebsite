<%@ Page Language="C#" AutoEventWireup="true" CodeFile="bbb.aspx.cs" Inherits="bbb" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>單字卡展示</title>
  <style>
    body {
        font-family: 'Segoe UI', sans-serif;
        background-color: #f9f9f9;
    }

    .word-card {
        border: 2px solid #d0d0d0;
        border-radius: 16px;
        padding: 14px 16px;
        margin: 16px auto;
        width: 92%;
        max-width: 600px;
        background-color: #ffffff;
        position: relative;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        display: flex;
        flex-direction: column;
    }

    .word-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .word-text {
        font-size: 22px;
        color: #00aacc;
        font-weight: bold;
    }

    .word-type {
        background-color: #eeeeee;
        color: #555;
        font-size: 13px;
        padding: 2px 8px;
        border-radius: 10px;
        margin-left: 8px;
    }

    .word-translation {
        margin-top: 6px;
        font-size: 16px;
        color: #444;
    }

    .word-actions {
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .word-actions button {
        background: none;
        border: none;
        font-size: 20px;
        cursor: pointer;
        color: #888;
    }

    .word-actions button:hover {
        color: #00aacc;
    }
</style>


    <script type="text/javascript">
        function playAudio(audioUrl) {
            const audio = new Audio(audioUrl);
            audio.play();
        }

        function showInfo(word) {
            alert("單字說明：" + word);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2 style="text-align: center;">地塊69 — 單字卡模擬</h2>

        <asp:Repeater ID="rptWords" runat="server">
            <ItemTemplate>
                <div class="word-card">
                    <div class="word-header">
                        <span class="word-text"><%# Eval("Word") %></span>
                        <span class="word-type"><%# Eval("Type") %></span>
                    </div>
                    <div class="word-translation">
                        <%# Eval("Chinese") %>
                    </div>
                    <div class="word-actions">
                        <button type="button" onclick="showInfo('<%# Eval("Word") %>')">i</button>
                        <button type="button" onclick="playAudio('<%# Eval("AudioUrl") %>')">🔊</button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </form>
</body>
</html>
