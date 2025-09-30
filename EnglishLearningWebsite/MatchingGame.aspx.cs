using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Diagnostics;

public partial class MatchingGame : System.Web.UI.Page
{
    private string connectionString;

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
        }
    }

    // 🔹 載入鑽石數量
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
}
