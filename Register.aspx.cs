using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Security.Cryptography;
using System.Text;
using BCrypt.Net; // ✅ 引入 Bcrypt


public partial class Register : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lblMessage.Text = "";
    }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        string username = txtUsername.Text.Trim();
        string fullName = txtFullName.Text.Trim();
        string email = txtEmail.Text.Trim();
        string password = txtPassword.Text.Trim();
        string confirmPassword = txtConfirmPassword.Text.Trim();
        string countryCode = ddlCountryCode.SelectedValue;
        string phoneNumber = txtPhoneNumber.Text.Trim();
        string gender = ddlGender.SelectedValue;
        string nationality = ddlNationality.SelectedValue;
        string birthday = txtBirthday.Text.Trim();


        // 🔹 **檢查所有欄位是否為空**
        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(fullName) ||
            string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password) ||
            string.IsNullOrWhiteSpace(confirmPassword) || string.IsNullOrWhiteSpace(phoneNumber) ||
            string.IsNullOrWhiteSpace(birthday))
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "所有欄位皆為必填，請完整填寫！";
            return;
        }

        // 🔹 限制 username 必須是 5~20 個字元
        if (!Regex.IsMatch(username, @"^[a-zA-Z0-9]{5,20}$"))
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "帳號名稱只能包含 5~20 個英文字母與數字！";
            return;
        }

        // 🔹 **驗證 Email 格式**
        if (!Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "請輸入有效的 Email 地址！";
            return;
        }

        // 🔹 **驗證密碼格式**
        if (!Regex.IsMatch(password, @"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()]).{8,}$"))
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "密碼需至少 8 個字符，包含大小寫字母、數字及特殊字元！";
            return;
        }

        // 🔹 **檢查密碼與確認密碼是否一致**
        if (password != confirmPassword)
        {
            lblMessage.CssClass = "text-danger d-block mt-3";
            lblMessage.Text = "密碼與確認密碼不一致！";
            return;
        }

        // ✅ **使用 Bcrypt 加密密碼**
        string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);
        // 🔹 **組合完整電話號碼**
        string fullPhoneNumber = countryCode + phoneNumber;

        string connString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connString))
        {
            conn.Open();
            SqlTransaction transaction = conn.BeginTransaction(); // ✅ 開啟交易

            try
            {
                // 🔹 **檢查 Email 是否已存在**
                string emailCheckQuery = "SELECT COUNT(*) FROM Users WHERE id_email = @Email";
                using (SqlCommand cmd = new SqlCommand(emailCheckQuery, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    int emailExists = (int)cmd.ExecuteScalar();
                    if (emailExists > 0)
                    {
                        lblMessage.CssClass = "text-danger d-block mt-3";
                        lblMessage.Text = "此 Email 已經註冊過，請使用其他 Email。";
                        transaction.Rollback(); // ❌ 回滾交易
                        return;
                    }
                }

                // 🔹 **檢查帳號是否已存在**
                string usernameCheckQuery = "SELECT COUNT(*) FROM Users WHERE username = @Username";
                using (SqlCommand cmd = new SqlCommand(usernameCheckQuery, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    int usernameExists = (int)cmd.ExecuteScalar();
                    if (usernameExists > 0)
                    {
                        lblMessage.CssClass = "text-danger d-block mt-3";
                        lblMessage.Text = "此帳號名稱已被使用，請選擇其他名稱。";
                        transaction.Rollback(); // ❌ 回滾交易
                        return;
                    }
                }

                // 🔹 **執行 `Users` 註冊操作**
                string insertUserQuery = @"
            INSERT INTO Users (username, name, id_email, password, phoneNumber, gender, nationality, birthday, created_at) 
            VALUES (@Username, @FullName, @Email, @Password, @PhoneNumber, @Gender, @Nationality, @Birthday, GETDATE()); 
            SELECT SCOPE_IDENTITY();"; // ✅ 取得新用戶的 `id`

                int userId;
                using (SqlCommand cmd = new SqlCommand(insertUserQuery, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@FullName", fullName);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Password", hashedPassword); // ✅ 存入加密密碼
                    cmd.Parameters.AddWithValue("@PhoneNumber", fullPhoneNumber);
                    cmd.Parameters.AddWithValue("@Gender", gender);
                    cmd.Parameters.AddWithValue("@Nationality", nationality);
                    cmd.Parameters.AddWithValue("@Birthday", birthday);

                    object result = cmd.ExecuteScalar();
                    if (result == null)
                    {
                        throw new Exception("❌ 無法獲取新用戶 ID，註冊失敗！");
                    }
                    userId = Convert.ToInt32(result);
                }

                // 🔹 **插入 `UserResources`（初始體力與鑽石）**
                string insertResourcesQuery = @"
            INSERT INTO UserResources (user_id, energy, diamonds, last_claimed)
            VALUES (@UserID, @Energy, @Diamonds, GETDATE());";

                using (SqlCommand cmd = new SqlCommand(insertResourcesQuery, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Energy", 50); // 初始體力 50
                    cmd.Parameters.AddWithValue("@Diamonds", 0); // 初始鑽石 0
                    cmd.ExecuteNonQuery();
                }

                // ✅ **交易提交**
                transaction.Commit();

                lblMessage.CssClass = "text-success d-block mt-3";
                lblMessage.Text = "註冊成功！正在為您導向登入畫面...。";

                System.Diagnostics.Debug.WriteLine($"✅ 註冊成功！UserID: {userId}");

                // **🔹 清空所有輸入欄位**
                txtUsername.Text = "";
                txtFullName.Text = "";
                txtEmail.Text = "";
                txtPassword.Text = "";
                txtConfirmPassword.Text = "";
                txtPhoneNumber.Text = "";
                txtBirthday.Text = "";
                ddlGender.SelectedIndex = 0;
                ddlNationality.SelectedIndex = 0;

                // 🔹 2 秒後導向登入頁面
                Response.AppendHeader("Refresh", "2;url=UserLogin.aspx");

                // 🔹 **立即執行 `preventUnloadOnSubmit()`，避免 Google 跳出離開提示**
                ScriptManager.RegisterStartupScript(this, GetType(), "preventUnload", "preventUnloadOnSubmit();", true);
            }
            catch (SqlException ex)
            {
                transaction.Rollback(); // ❌ SQL 錯誤時回滾交易

                if (ex.Number == 2627) // 違反 UNIQUE 限制
                {
                    lblMessage.CssClass = "text-danger d-block mt-3";
                    lblMessage.Text = "帳號名稱或 Email 已存在，請更換後再試。";
                }
                else if (ex.Number == 547) // 違反 CHECK 限制 (密碼規則)
                {
                    lblMessage.CssClass = "text-danger d-block mt-3";
                    lblMessage.Text = "密碼不符合安全性規則，請重新輸入。";
                }
                else
                {
                    lblMessage.CssClass = "text-danger d-block mt-3";
                    lblMessage.Text = "發生錯誤，請稍後再試。";
                }
            }
            catch (Exception ex)
            {
                transaction.Rollback(); // ❌ 其他未知錯誤時回滾交易
                System.Diagnostics.Debug.WriteLine($"❌ 未知錯誤: {ex.Message}");

                lblMessage.CssClass = "text-danger d-block mt-3";
                lblMessage.Text = "發生未知錯誤，請稍後再試！";
            }
        }
    }
    // 🔹 回首頁
    protected void btnHome_Click(object sender, EventArgs e)
    {
        Response.Redirect("HomePage.aspx");
    }

}



