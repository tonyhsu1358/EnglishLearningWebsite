<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserLogin.aspx.cs" Inherits="UserLogin" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>使用者登入</title>

    <!-- 引入 Bootstrap 5 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" />
    <!-- 引入 Bootstrap Icons -->

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
            background: rgba(0, 0, 0, 0.5);
            z-index: 0;
        }

        .login-container {
            max-width: 400px;
            padding: 30px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            text-align: center;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.2);
            position: relative;
            z-index: 1;
        }

        /* 讓密碼眼睛按鈕更好點擊 */
        .toggle-password {
            cursor: pointer;
            user-select: none;
        }
    </style>

    <script>
        function validateEmail() {
            var email = document.getElementById('<%= txtUsername.ClientID %>').value;
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // 允許任何 Email 格式
            if (!emailRegex.test(email)) {
                alert("請輸入有效的 Email 地址");
                return false;
            }
            return true;
        }

        // 🔹 切換密碼顯示與隱藏
        function togglePassword() {
            var passwordField = document.getElementById('<%= txtPassword.ClientID %>');
            var toggleIcon = document.getElementById("toggleIcon");

            if (passwordField.type === "password") {
                passwordField.type = "text";
                toggleIcon.classList.remove("bi-eye");
                toggleIcon.classList.add("bi-eye-slash"); // 變成 "隱藏" 圖示
            } else {
                passwordField.type = "password";
                toggleIcon.classList.remove("bi-eye-slash");
                toggleIcon.classList.add("bi-eye"); // 變回 "顯示" 圖示
            }
        }
        // 🔹 登入成功後，禁用帳號、密碼輸入框與登入按鈕
        function disableInputs() {
            document.getElementById('<%= txtUsername.ClientID %>').disabled = true;
            document.getElementById('<%= txtPassword.ClientID %>').disabled = true;
            document.getElementById('<%= btnLogin.ClientID %>').disabled = true;
            document.getElementById('<%= btnHome.ClientID %>').disabled = true; // 回首頁按鈕
        }

    </script>
</head>

<body class="d-flex align-items-center justify-content-center vh-100">
    <div class="overlay"></div>
    <!-- 背景透明層 -->

    <form id="form1" runat="server">
        <div class="login-container">
            <h2 class="mb-4"><i class="bi bi-person-circle"></i>使用者登入</h2>

            <!-- Email 輸入框 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="請輸入 Email"></asp:TextBox>
            </div>

            <!-- 密碼輸入框 -->
            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="請輸入密碼"></asp:TextBox>
                <span class="input-group-text toggle-password" onclick="togglePassword()">
                    <i id="toggleIcon" class="bi bi-eye"></i>
                    <!-- 眼睛圖示 -->
                </span>
            </div>

            <!-- 登入按鈕 -->
            <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-primary w-100 d-flex align-items-center justify-content-center"
                Text=" 確認登入" OnClick="btnLogin_Click" OnClientClick="return validateEmail();" />

            <!-- 忘記密碼 & 註冊帳號 -->
            <div class="d-flex justify-content-between mt-3">
                <a href="ForgotPassword.aspx" class="text-primary">
                    <i class="bi bi-arrow-clockwise"></i>忘記密碼？
                </a>
                <a href="Register.aspx" class="text-primary">
                    <i class="bi bi-pencil-square"></i>註冊帳號
                </a>
            </div>

            <!-- 登入結果訊息 -->
            <asp:Label ID="lblMessage" runat="server" CssClass="text-danger d-block mt-3"></asp:Label>

            <!-- 回首頁按鈕 -->
            <asp:Button ID="btnHome" runat="server" CssClass="btn btn-secondary w-100 mt-3 d-flex align-items-center justify-content-center"
                Text=" 回首頁" OnClick="btnHome_Click" />
        </div>
    </form>

    <!-- 引入 Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
