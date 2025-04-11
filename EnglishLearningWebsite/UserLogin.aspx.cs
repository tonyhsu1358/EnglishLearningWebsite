using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using BCrypt.Net; // ✅ 引入 BCrypt 套件

public partial class UserLogin : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lblMessage.Text = "";

        if (Session["UserEmail"] != null)
        {
            // ✅ 每次使用者有操作，就讓 Session 重新計時
            Session.Timeout = 240;  // **設定 60 分鐘的 Session**
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text.Trim();

        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "請輸入 Email 和密碼！";
            return;
        }

        if (!Regex.IsMatch(username, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "請輸入有效的 Email 地址！";
            return;
        }

        string connString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connString))
        {
            conn.Open();
            string query = "SELECT password FROM dbo.Users WHERE id_email = @Email";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Email", username);
                object storedPasswordObj = cmd.ExecuteScalar();

                if (storedPasswordObj == null)
                {
                    lblMessage.CssClass = "text-warning d-block mt-3";
                    lblMessage.Text = "此 Email 尚未註冊！請先註冊帳號。";
                    return;
                }

                string storedHashedPassword = storedPasswordObj.ToString();

                if (BCrypt.Net.BCrypt.Verify(password, storedHashedPassword))
                {
                    // ✅ 設定 Session，並確保 60 分鐘內不會過期
                    Session["UserEmail"] = username;
                    Session.Timeout = 240;  // **讓 Session 在 60 分鐘內不會過期**

                    // **加入 Debug 紀錄**
                    System.Diagnostics.Debug.WriteLine($"✅ [INFO] 使用者登入成功 - Session ID: {Session.SessionID} - Email: {username}");

                    ScriptManager.RegisterStartupScript(this, GetType(), "disableInputs", "disableInputs();", true);
                    lblMessage.CssClass = "text-success d-block mt-3";
                    lblMessage.Text = "登入成功！";

                    Response.AppendHeader("Refresh", "1;url=HomePage.aspx");
                }
                else
                {
                    lblMessage.CssClass = "text-danger d-block mt-3";
                    lblMessage.Text = "帳號或密碼錯誤，請重試！";
                }
            }
        }
    }
    // 🔹 回首頁
    protected void btnHome_Click(object sender, EventArgs e)
    {
        Response.Redirect("HomePage.aspx");
    }
}
