using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

public partial class ListeningTest : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDiamonds(); // 🔹 加這行
            LoadTopics();
        }
    }

    private void LoadDiamonds()
    {
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // 假設 Session["UserID"] 已經存在
            int userId = Convert.ToInt32(Session["UserID"]);

            string query = "SELECT diamonds FROM UserResources WHERE user_id = @UserID";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                object result = cmd.ExecuteScalar();
                lblDiamonds.Text = (result != null) ? result.ToString() : "0";
            }
        }
    }

    private void LoadTopics()
    {
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string query = "SELECT TopicID, TopicName, ImagePath, Description FROM Listening_Topics ORDER BY Priority ASC";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                SqlDataReader reader = cmd.ExecuteReader();
                rptTopics.DataSource = reader;
                rptTopics.DataBind();
            }
        }
    }


    protected void btnStart_Click(object sender, EventArgs e)
    {
        // TODO: 把選到的題數與主題存 Session 或 QueryString
        Response.Redirect("DoListeningTest.aspx");
    }

    protected void btnBack_Click(object sender, EventArgs e)
    {
        Response.Redirect("HomePage.aspx");
    }
}
