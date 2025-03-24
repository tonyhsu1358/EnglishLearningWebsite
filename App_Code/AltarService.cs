using System;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data.SqlClient;
using System.Configuration;

/// <summary>
/// AltarService 的摘要描述
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 支援從 JS 使用 AJAX 呼叫
public class AltarService : WebService
{
    [WebMethod(EnableSession = true)]
    public object GetAltarStatus(int altarId)
    {
        try
        {
            // ✅ 確認 Session 是否存在
            if (HttpContext.Current.Session["UserID"] == null)
            {
                return new { error = "NOT_LOGGED_IN" };
            }

            int userId = (int)HttpContext.Current.Session["UserID"];
            int learningStatus = 0;
            int daysSinceReview = 0;

            string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string query = @"
                    SELECT learning_status, last_review_time
                    FROM user_altar_progress
                    WHERE user_id = @UserID AND altar_id = @AltarID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@AltarID", altarId);

                SqlDataReader reader = cmd.ExecuteReader();
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

            return new { learningStatus, daysSinceReview };
        }
        catch (Exception ex)
        {
            // ✅ 回傳錯誤給前端方便除錯
            return new { error = "INTERNAL_ERROR", message = ex.Message };
        }
    }
}
