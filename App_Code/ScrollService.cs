using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService] // ✅ 允許前端 AJAX 呼叫此 WebMethod
public class ScrollService : System.Web.Services.WebService
{
    public ScrollService() { }

    // ✅ 取得指定祭壇的單字列表，包含是否為最愛
    [WebMethod(EnableSession = true)]
    public List<object> GetScrollWords(int altarId)
    {
        var results = new List<object>();

        if (HttpContext.Current.Session["UserID"] == null)
            return results;

        int userId = (int)HttpContext.Current.Session["UserID"];
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string query = @"
    WITH FirstMeaning AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY word ORDER BY scroll_id) AS rn
        FROM ancient_scrolls
        WHERE altar_id = @AltarID
    )
    SELECT 
        fm.scroll_id,
        fm.word,
        fm.part_of_speech,
        fm.meaning,
        fm.word_audio_url,
        CASE 
            WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 
        END AS is_favorite
    FROM FirstMeaning fm
    LEFT JOIN user_favorite_words f
        ON fm.scroll_id = f.scroll_id AND f.user_id = @UserID
    WHERE fm.rn = 1
    ORDER BY fm.word";


            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@UserID", userId);
            cmd.Parameters.AddWithValue("@AltarID", altarId);

            SqlDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                results.Add(new
                {
                    scroll_id = (int)reader["scroll_id"],
                    word = reader["word"].ToString(),
                    part_of_speech = reader["part_of_speech"].ToString(),
                    meaning = reader["meaning"].ToString(),
                    word_audio_url = reader["word_audio_url"]?.ToString(),
                    is_favorite = Convert.ToBoolean(reader["is_favorite"])
                });
            }
        }

        return results;
    }

    // ✅ 新增或移除收藏
    [WebMethod(EnableSession = true)]
    public string UpdateFavorite(int scrollId, bool isFavorite)
    {
        string userIdStr = HttpContext.Current.Session["UserID"]?.ToString();
        if (string.IsNullOrEmpty(userIdStr)) return "未登入";

        int userId = int.Parse(userIdStr);
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd;

            if (isFavorite)
            {
                // 加入收藏（避免重複）
                cmd = new SqlCommand(@"
                    IF NOT EXISTS (
                        SELECT 1 FROM user_favorite_words WHERE user_id = @UserID AND scroll_id = @ScrollID
                    )
                    BEGIN
                        INSERT INTO user_favorite_words (user_id, scroll_id)
                        VALUES (@UserID, @ScrollID)
                    END
                ", conn);
            }
            else
            {
                // 移除收藏
                cmd = new SqlCommand(@"
                    DELETE FROM user_favorite_words
                    WHERE user_id = @UserID AND scroll_id = @ScrollID
                ", conn);
            }

            cmd.Parameters.AddWithValue("@UserID", userId);
            cmd.Parameters.AddWithValue("@ScrollID", scrollId);
            cmd.ExecuteNonQuery();

            return isFavorite ? "已加入收藏" : "已取消收藏";
        }
    }
}