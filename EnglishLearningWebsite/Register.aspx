<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>註冊帳號</title>

    <!-- 引入 Bootstrap 5 和 FontAwesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />

    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: url('images/learn-english.png') no-repeat center center fixed;
            background-size: cover;
            position: relative;
        }

        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.5);
            z-index: 0;
        }

        .register-container {
            max-width: 450px;
            padding: 30px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 10px;
            text-align: center;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.2);
            position: relative;
            z-index: 1;
        }

        .input-group-text {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center min-vh-100">

    <div class="overlay"></div>

    <form id="form1" runat="server" onsubmit="return preventUnloadOnSubmit(event);">

        <div class="register-container">
            <h2 class="mb-4">註冊帳號</h2>

            <!-- 帳號名稱 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-user"></i></span>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="帳號名稱"></asp:TextBox>
            </div>

            <!-- 姓名 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-id-card"></i></span>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="姓名"></asp:TextBox>
            </div>

            <!-- Email -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email"></asp:TextBox>
            </div>

            <!-- 生日 -->
            <div class="mb-3">
                <div class="input-group">
                    <span class="input-group-text"><i class="fa-solid fa-cake-candles"></i></span>
                    <asp:TextBox ID="txtBirthday" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
            </div>

            <!-- 密碼 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="密碼"></asp:TextBox>
                <span class="input-group-text" onclick="togglePassword('txtPassword', 'togglePasswordIcon1')">
                    <i id="togglePasswordIcon1" class="fa-solid fa-eye-slash"></i>
                </span>
            </div>

            <!-- 確認密碼 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="確認密碼"></asp:TextBox>
                <span class="input-group-text" onclick="togglePassword('txtConfirmPassword', 'togglePasswordIcon2')">
                    <i id="togglePasswordIcon2" class="fa-solid fa-eye-slash"></i>
                </span>
            </div>

            <!-- 手機號碼 -->
            <div class="mb-3 row">
                <div class="col-4">
                    <asp:DropDownList ID="ddlCountryCode" runat="server" CssClass="form-select text-center">
                        <asp:ListItem Value="+886">🇹🇼 +886</asp:ListItem>
                        <asp:ListItem Value="+1">🇺🇸 +1</asp:ListItem>
                        <asp:ListItem Value="+81">🇯🇵 +81</asp:ListItem>
                        <asp:ListItem Value="+86">🇨🇳 +86</asp:ListItem>
                        <asp:ListItem Value="+44">🇬🇧 +44</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-8 input-group">
                    <span class="input-group-text"><i class="fa-solid fa-phone"></i></span>
                    <asp:TextBox ID="txtPhoneNumber" runat="server" CssClass="form-control" placeholder="手機號碼(開頭勿+0，否則學習效率只有25%)"></asp:TextBox>
                </div>
            </div>

            <!-- 性別 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-venus-mars"></i></span>
                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                    <asp:ListItem Value="Male">男</asp:ListItem>
                    <asp:ListItem Value="Female">女</asp:ListItem>
                    <asp:ListItem Value="Other">不願透露</asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- 國籍 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="fa-solid fa-map-marker-alt"></i></span>
                <asp:DropDownList ID="ddlNationality" runat="server" CssClass="form-select">
                    <asp:ListItem Value="TW">台灣</asp:ListItem>
                    <asp:ListItem Value="US">美國</asp:ListItem>
                    <asp:ListItem Value="JP">日本</asp:ListItem>
                    <asp:ListItem Value="CN">中國</asp:ListItem>
                    <asp:ListItem Value="Other">其他國家</asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- 註冊按鈕 -->
            <asp:Button ID="btnRegister" runat="server" CssClass="btn btn-success w-100" Text="註冊" OnClick="btnRegister_Click" />

            <asp:Label ID="lblMessage" runat="server" CssClass="text-danger d-block mt-3"></asp:Label>

            <!-- 已有帳號連結 -->
            <a href="UserLogin.aspx" class="btn btn-link d-block mt-3" onclick="return confirmLeave();">已有帳號？登入</a>
            <!-- 回首頁按鈕 -->
            <asp:Button ID="btnHome" runat="server" CssClass="btn btn-light w-100 mt-3"
                Text="回首頁" OnClientClick="return confirmLeave();" OnClick="btnHome_Click" />

        </div>
    </form>

    <!-- 引入 Bootstrap 5 JS 和 FontAwesome -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- 防止未提交離開 -->
    <script>
        var isSubmitting = false; // 追蹤是否已提交表單

        function preventUnloadOnSubmit() {
            isSubmitting = true; // 避免跳出提示
            return true;
        }

        function confirmLeave() {
            if (!isSubmitting) {
                var leaveConfirmed = confirm("您的資料尚未提交，確定要離開此頁面嗎？");
                return leaveConfirmed; // 如果用戶選擇 "否"，則阻止跳轉
            }
            return true;
        }
    </script>

    <!-- 密碼顯示/隱藏功能 -->
    <script>
        function togglePassword(inputId, iconId) {
            var passwordInput = document.getElementById(inputId);
            var icon = document.getElementById(iconId);

            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            } else {
                passwordInput.type = "password";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            }
        }
    </script>

    <!-- 防止未提交離開 -->
    <script>
        var isSubmitting = false; // 追蹤是否已提交表單

        window.onbeforeunload = function () {
            if (!isSubmitting) {
                return "您的資料尚未提交，確定要離開此頁面嗎？";
            }
        };

        function preventUnloadOnSubmit() {
            window.onbeforeunload = null; // **完全移除 Google 內建的離開提示**
            isSubmitting = true; // 避免跳出提示

            return true;
        }

        function confirmLeave() {
            if (!isSubmitting) {
                var leaveConfirmed = confirm("您的資料尚未提交，確定要離開此頁面嗎？");
                if (!leaveConfirmed) {
                    return false; // 停止跳轉
                }
            }
            window.onbeforeunload = null; // 防止額外彈窗
            return true;
        }
    </script>
</body>
</html>
