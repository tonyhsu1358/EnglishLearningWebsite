using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics; // 🔹 用於 Debug 訊息

// 🔹 這個類別對應 ASPX 頁面，負責處理伺服器端的行為
public partial class HomePage : System.Web.UI.Page
{
    // 🔹 頁面加載事件
    protected void Page_Load(object sender, EventArgs e)
    {
        Debug.WriteLine("🔹 Page_Load() - 頁面載入");

        if (Session["UserEmail"] != null) // ✅ 用戶已登入
        {
            string userEmail = Session["UserEmail"].ToString();
            Debug.WriteLine($"🔹 Page_Load() - 目前登入用戶: {userEmail}");

            // ✅ 先檢查今天是否已經領取體力
            bool receivedEnergy = CheckAndUpdateDailyEnergy(userEmail);
            if (receivedEnergy)
            {
                Debug.WriteLine("🎉 Page_Load() - 今日成功領取 10 點體力！");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showTooltip", "showEnergyTooltip();", true);
            }
        }

        // ✅ 更新導覽列 UI
        if (!IsPostBack)
        {
            Debug.WriteLine("🔹 Page_Load() - 執行 UpdateNavbar()");
            UpdateNavbar();
        }
    }

    // 🔹 更新導覽列（判斷用戶是否登入，顯示對應的 UI）
    private void UpdateNavbar()
    {
        Debug.WriteLine("🔹 UpdateNavbar() - 開始執行");

        if (Session["UserEmail"] != null) // ✅ 用戶已登入
        {
            string userEmail = Session["UserEmail"].ToString();
            string userName;
            int energy, diamonds;

            Debug.WriteLine($"🔹 UpdateNavbar() - 目前登入用戶: {userEmail}");

            // ✅ 取得用戶名稱 & 體力 & 鑽石
            if (GetUserResources(userEmail, out userName, out energy, out diamonds))
            {
                Debug.WriteLine($"✅ 用戶 {userName} 體力: {energy}, 鑽石: {diamonds}");

                btnLogin.Visible = false;  // 隱藏「登入 / 註冊」按鈕
                lblUserName.Text = $"歡迎, {userName}";  // 顯示用戶名稱
                lblEnergy.Text = energy.ToString();   // 顯示體力數值
                lblDiamonds.Text = diamonds.ToString(); // 顯示鑽石數值
                btnLogout.Visible = true;  // 顯示「登出」按鈕

                // ✅ 顯示體力與鑽石
                energyContainer.Visible = true;
                diamondsContainer.Visible = true;
            }
            else
            {
                Debug.WriteLine("❌ GetUserResources() 無法獲取用戶資料");
            }
        }
        else // ✅ 用戶未登入
        {
            Debug.WriteLine("🔹 UpdateNavbar() - 用戶未登入");

            btnLogin.Visible = true;  // 顯示「登入 / 註冊」按鈕
            lblUserName.Text = "";
            lblEnergy.Text = "";
            lblDiamonds.Text = "";
            btnLogout.Visible = false; // 隱藏「登出」按鈕

            // ❌ 隱藏體力與鑽石
            energyContainer.Visible = false;
            diamondsContainer.Visible = false;
        }
    }

    // 🔹 讀取使用者的體力與鑽石
    private bool GetUserResources(string email, out string userName, out int energy, out int diamonds)
    {
        Debug.WriteLine($"🔹 GetUserResources() - 查詢用戶: {email}");

        string connString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        userName = "";
        energy = 0;
        diamonds = 0;

        using (SqlConnection conn = new SqlConnection(connString))
        {
            conn.Open();
            string query = @"
                SELECT u.name, r.energy, r.diamonds
                FROM Users u
                JOIN UserResources r ON u.user_id = r.user_id
                WHERE u.id_email = @Email";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    userName = reader["name"].ToString();
                    energy = Convert.ToInt32(reader["energy"]);
                    diamonds = Convert.ToInt32(reader["diamonds"]);
                    Debug.WriteLine($"✅ 取得資料 - 使用者: {userName}, 體力: {energy}, 鑽石: {diamonds}");
                    return true;
                }
                else
                {
                    Debug.WriteLine("❌ 無法找到該 Email 的用戶資料");
                }
            }
        }
        return false;
    }

    // 🔹 每日登入領取體力（一天只能領一次）
    private bool CheckAndUpdateDailyEnergy(string email)
    {
        Debug.WriteLine($"🔹 CheckAndUpdateDailyEnergy() - 檢查用戶: {email}");

        string connString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        bool receivedEnergy = false;

        using (SqlConnection conn = new SqlConnection(connString))
        {
            conn.Open();

            // 取得用戶 ID 與上次領取體力的時間
            string query = @"
                SELECT r.user_id, r.energy, r.last_claimed 
                FROM Users u 
                JOIN UserResources r ON u.user_id = r.user_id 
                WHERE u.id_email = @Email";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    int userId = Convert.ToInt32(reader["user_id"]);
                    int currentEnergy = Convert.ToInt32(reader["energy"]);
                    DateTime? lastClaimed = reader["last_claimed"] as DateTime?;

                    Debug.WriteLine($"🔹 用戶 ID: {userId}, 當前體力: {currentEnergy}, 上次領取: {lastClaimed}");

                    // 檢查 `last_claimed` 是否為今天
                    if (!lastClaimed.HasValue || lastClaimed.Value.Date < DateTime.UtcNow.Date)
                    {
                        reader.Close();

                        // 更新體力並記錄領取時間
                        string updateQuery = @"
                            UPDATE UserResources 
                            SET energy = energy + 10, last_claimed = GETUTCDATE() 
                            WHERE user_id = @UserId";

                        using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                        {
                            updateCmd.Parameters.AddWithValue("@UserId", userId);
                            updateCmd.ExecuteNonQuery();
                            Debug.WriteLine("✅ 今日成功領取 10 點體力！");
                            receivedEnergy = true;
                        }
                    }
                    else
                    {
                        Debug.WriteLine("❌ 今日已領取體力，無法重複領取");
                    }
                }
            }
        }
        return receivedEnergy;
    }

    // 🔹 點擊「開始遊玩」按鈕時
    protected void btnCourse_Click(object sender, EventArgs e)
    {
        if (Session["UserEmail"] == null) // ✅ 未登入
        {
            Response.Redirect("UserLogin.aspx?returnUrl=HomePage.aspx");
            return;
        }

        Button clickedButton = sender as Button;
        if (clickedButton != null)
        {
            string courseId = clickedButton.CommandArgument;

            if (courseId == "1") // ✅ 如果是「背單字」
            {
                // 先導向 "SelectVocabularyLevel.aspx"，讓用戶選擇 CEFR 等級
                Response.Redirect($"SelectVocabularyLevel.aspx?courseId={courseId}");
            }
            else
            {
                Response.Redirect($"CourseDetails.aspx?id={courseId}");
            }
        }
    }

    // 🔹 點擊「登出」按鈕時，清除 Session，返回首頁
    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Debug.WriteLine("🔹 btnLogout_Click() - 用戶登出");

        Session.Clear();
        Response.Redirect("HomePage.aspx");
    }
}