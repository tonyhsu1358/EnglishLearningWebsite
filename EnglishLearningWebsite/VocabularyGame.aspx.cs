using System;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;
using System.Configuration; // 引入 ConfigurationManager
using System.Web.Services; // ✅ 確保加上這個
public partial class VocabularyGame : System.Web.UI.Page
{
    //==============================================
    // 1.頁面初始化邏輯🔷 1. 初始化 / 頁面載入相關這是入口，負責從資料庫抓資料來初始化 UI 畫面。
    //==============================================
    private string connectionString;
    //方法1.1-首次載入頁面此方法負責頁面首次載入時的初始化工作，包括驗證使用者登入、呼叫方法取得使用者和森林資訊等等
    protected void Page_Load(object sender, EventArgs e)
    {
        Debug.WriteLine(" [Page_Load] - 頁面載入開始");

        connectionString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        // 驗證登入狀態
        if (Session["UserEmail"] == null)
        {
            Debug.WriteLine("❌ [Page_Load] - 使用者未登入，Session 無效");
            Response.Redirect("UserLogin.aspx");
            return;
        }

        // 取得 UserID
        if (Session["UserID"] == null)
        {
            string userEmail = Session["UserEmail"].ToString();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "SELECT user_id FROM users WHERE id_email = @Email";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", userEmail);
                    object result = cmd.ExecuteScalar();

                    if (result == null)
                    {
                        Debug.WriteLine("❌ [Page_Load] - 查無使用者：" + userEmail);
                        Response.Redirect("UserLogin.aspx");
                        return;
                    }

                    Session["UserID"] = Convert.ToInt32(result);
                    Debug.WriteLine("✅ [Page_Load] - 登入者 UserID：" + Session["UserID"]);
                }
            }
        }

        // 取得 QueryString["level"] 並對應森林 ID 與名稱
        string levelStr = Request.QueryString["level"];
        if (!string.IsNullOrEmpty(levelStr))
        {
            int level = int.Parse(levelStr);
            int forestId = 1;

            switch (level)
            {
                case 1: forestId = 1; break;
                case 2: forestId = 2; break;
                case 3: forestId = 3; break;
                case 4: forestId = 4; break;
                case 5: forestId = 5; break;
                case 6: forestId = 6; break;
                case 7: forestId = 7; break;
                default: forestId = 1; break;
            }

            Session["SelectedForestID"] = forestId;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "SELECT forest_name_zh FROM magic_forest WHERE forest_id = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", forestId);
                    object name = cmd.ExecuteScalar();
                    string forestName = name != null ? name.ToString() : "未知森林";

                    // 顯示在畫面上
                    lblForestName.Text = forestName;

                    // ✅ ✅ ✅ 加入 DEBUG LOG
                    Debug.WriteLine($"🌲 [Page_Load] - 使用者切換到森林 ID: {forestId}，名稱：{forestName}");
                }
            }
        }
        else
        {
            Debug.WriteLine("❌ [Page_Load] - 無 level 參數");
        }

        // 初次載入時執行初始化
        if (!IsPostBack)
        {
            try
            {
                LoadUserStats();
                LoadMagicForests();
                LoadMagicAltars();
                hiddenUserId.Value = Session["UserID"].ToString();

                if (Request.QueryString["startTrial"] != null)
                {
                    int altarId = int.Parse(Request.QueryString["startTrial"]);
                    StartTrial(altarId);
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ [Page_Load] 發生錯誤：" + ex.Message);
            }
        }
        // ✅ 捕捉 __doPostBack 觸發的事件名
        string eventTarget = Request["__EVENTTARGET"];
        Debug.WriteLine("🧪 EVENTTARGET: " + eventTarget);
        if (eventTarget == "QueryAltarStatus")
        {
            int userId = (int)Session["UserID"];
            int altarId = int.Parse(hiddenAltarId.Value);

            int learningStatus = 0;
            int daysSinceReview = 0;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
            SELECT learning_status, last_review_time
            FROM user_altar_progress
            WHERE user_id = @UserID AND altar_id = @AltarID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@AltarID", altarId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            learningStatus = reader["learning_status"] != DBNull.Value ? Convert.ToInt32(reader["learning_status"]) : 0;

                            if (reader["last_review_time"] != DBNull.Value)
                            {
                                DateTime lastReview = Convert.ToDateTime(reader["last_review_time"]);
                                daysSinceReview = (DateTime.Now - lastReview).Days;
                            }
                        }
                    }
                }
            }
            // ✅ 呼叫 JS 函式，丟回去顯示
            string js = $@"
    setTimeout(function() {{
        showAltarPanel({altarId}, {learningStatus}, {daysSinceReview});
    }}, 0);
";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "updateAltarPanel", js, true);
        }
    }

    //方法1.2-從資料庫讀取使用者的魔法能量和鑽石數量，並將其顯示在頁面上。
    private void LoadUserStats()
    {
        Debug.WriteLine(" [LoadUserStats] - 讀取使用者體力與鑽石");

        string query = "SELECT energy, diamonds FROM UserResources WHERE user_id = @UserID";

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", (int)Session["UserID"]);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblEnergy.Text = reader["energy"].ToString();
                    lblDiamonds.Text = reader["diamonds"].ToString();
                    Debug.WriteLine($"✅ [LoadUserStats] 體力: {lblEnergy.Text}，鑽石: {lblDiamonds.Text}");
                }
                else
                {
                    lblEnergy.Text = "0";
                    lblDiamonds.Text = "0";
                    Debug.WriteLine("⚠ [LoadUserStats] 找不到使用者資源資料，預設為 0");
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ [LoadUserStats] 發生錯誤：" + ex.Message);
            }
        }
    }

    //方法1.3-從資料庫載入所有魔法森林的ID和名稱，並將它們記錄到Debug輸出中，但沒實際用在前端
    private void LoadMagicForests()
    {
        Debug.WriteLine(" [LoadMagicForests] - 開始載入魔法森林");

        string query = "SELECT forest_id, forest_name_zh FROM magic_forest";

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(query, conn);
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    string forestId = reader["forest_id"].ToString();
                    string forestName = reader["forest_name_zh"].ToString();

                    Debug.WriteLine($"✅ [LoadMagicForests] 成功載入：{forestName}（ID: {forestId}）");
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ [LoadMagicForests] 發生錯誤：" + ex.Message);
            }
        }
    }
    //方法1.4-從資料庫載入對應的魔法祭壇，並根據使用者的學習進度，動態生成包含祭壇按鈕的HTML網格，顯示在頁面上。
    private void LoadMagicAltars()
    {
        if (Session["SelectedForestID"] == null)
        {
            Debug.WriteLine("❌ [LoadMagicAltars] - 尚未設定森林 ID");
            return;
        }

        int forestId = (int)Session["SelectedForestID"];
        int userId = (int)Session["UserID"];

        string query = @"
    SELECT ma.altar_id, COALESCE(up.learning_status, 0) AS learning_status
    FROM magic_altar ma
    LEFT JOIN user_altar_progress up
        ON ma.altar_id = up.altar_id AND up.user_id = @UserID
    WHERE ma.forest_id = @ForestID";

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            try
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@ForestID", forestId);

                SqlDataReader reader = cmd.ExecuteReader();
                StringBuilder altarHtml = new StringBuilder(); // ⚠️ 不要有多餘 <div>！

                while (reader.Read())
                {
                    int altarId = Convert.ToInt32(reader["altar_id"]);
                    int status = Convert.ToInt32(reader["learning_status"]);
                    string cssClass = "locked";

                    if (status == 0)
                        cssClass = "locked";
                    else if (status >= 1 && status < 7)
                        cssClass = "learning";
                    else if (status == 999)
                        cssClass = "withered";
                    else if (status >= 7)
                        cssClass = "completed";

                    // 加入 100 顆祭壇按鈕
                    altarHtml.AppendFormat(
                      "<button type='button' class='altar-button {0}' onclick='showAltarOptions({1})'>{1}</button>",
                       cssClass, altarId
                    );
                }
                altarHtml.Append("</div>");
                litAltarGrid.Text = altarHtml.ToString();// 一次 assign 就好
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ [LoadMagicAltars] 發生錯誤：" + ex.Message);
            }
        }
    }

    //==============================================
    // 2. 下拉選單 / 控制項觸發事件🔷這區是當使用者操作 UI 控制項時，後端要做的事。
    //==============================================

    //方法2.1-此為pnlMagicForest儀表板內的按鈕事件，點選後導向森林選擇頁面
    protected void btnSwitchForest_Click(object sender, EventArgs e)
    {
        Response.Redirect("SelectVocabularyLevel.aspx");
    }
    //方法2.2-此為pnlMagicForest儀表板內的按鈕事件，點選後導向首頁
    protected void btnBackHome_Click(object sender, EventArgs e)
    {
        Response.Redirect("HomePage.aspx");
    }
    //方法2.3-此為pnlAncientScroll儀表板內的按鈕事件，可讓使用者跳轉至統計結果
    protected void btnViewStats_Click(object sender, EventArgs e)
    {
        Response.Redirect("Statics.aspx");
    }

    //==============================================
    //  3. 學習流程邏輯🔷包含進入祭壇學單字、開始測驗的業務邏輯。
    //==============================================
    //方法3.1-開始測驗
    protected void StartTrial(int altarId)
    {
        Debug.WriteLine($" [StartTrial] - 祭壇 {altarId} 測驗開始");
        pnlMagicAltar.Visible = false;
        //pnlTrialChamber.Visible = true;
    }

}