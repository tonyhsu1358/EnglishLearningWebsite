using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Diagnostics;

public partial class ListeningTest : System.Web.UI.Page
{
    private string connectionString;
    //=================================
    //====第零章:初始必要方法載入
    //=================================
    //0-1.首次載入網頁呼叫必要方法
    protected void Page_Load(object sender, EventArgs e)
    {
        connectionString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        // ✅ 驗證使用者是否登入
        if (Session["UserEmail"] == null)
        {
            Debug.WriteLine("❌ [Page_Load] - 使用者未登入，Session 無效");
            Response.Redirect("UserLogin.aspx");
            return;
        }

        // ✅ 確保 Session["UserID"] 有值
        if (Session["UserID"] == null)
        {
            string userEmail = Session["UserEmail"].ToString();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "SELECT user_id FROM Users WHERE id_email = @Email";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", userEmail);
                    object result = cmd.ExecuteScalar();

                    if (result == null)
                    {
                        Debug.WriteLine("❌ [Page_Load] - 查無此使用者：" + userEmail);
                        Response.Redirect("UserLogin.aspx");
                        return;
                    }

                    Session["UserID"] = Convert.ToInt32(result);
                    Debug.WriteLine("✅ [Page_Load] - 取得 UserID：" + Session["UserID"]);
                }
            }
        }

        if (!IsPostBack)
        {
            LoadDiamonds();
            LoadTopics();
        }
    }

    //0-1.讀取鑽石數量
    private void LoadDiamonds()
    {
        int userId = (int)Session["UserID"];

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            string query = "SELECT diamonds FROM UserResources WHERE user_id = @UserID";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                object result = cmd.ExecuteScalar();

                lblDiamonds.Text = (result != null) ? result.ToString() : "0";

                Debug.WriteLine($"💎 [LoadDiamonds] - UserID {userId} 擁有鑽石數量：{lblDiamonds.Text}");
            }
        }
    }

    //0-2.載入題目主題
    private void LoadTopics()
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            string query = @"
        SELECT t.TopicID, t.TopicName, t.ImagePath, t.Description, 
               COUNT(q.QuestionID) AS QuestionCount   -- 🚩 新增：計算每個主題的題目數
        FROM Listening_Topics t
        LEFT JOIN Listening_Questions q ON t.TopicID = q.TopicID
        WHERE t.IsActive = 1                         -- 🚩 只撈啟用中的主題
        GROUP BY t.TopicID, t.TopicName, t.ImagePath, t.Description, t.Priority
        ORDER BY t.Priority ASC";                    // 🚩 按優先權排序

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                SqlDataReader reader = cmd.ExecuteReader();
                rptTopics.DataSource = reader;           // 🚩 綁定到 Repeater
                rptTopics.DataBind();
            }
        }
    }
    //0-3.返回首頁按鈕
    protected void btnBack_Click(object sender, EventArgs e)
    {
        Response.Redirect("HomePage.aspx");
    }
}
