using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService]
public class FirstLearningService : WebService
{
    [WebMethod(EnableSession = true)]
    public List<object> GetFirstLearningWords(int altarId)
    {
        // 1. 驗證登入狀態
        if (HttpContext.Current.Session["UserID"] == null)
            return new List<object> { new { error = "NOT_LOGGED_IN" } };

        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        var results = new List<object>();

        // 2. 撈出所有 priority_level = 1 的單字，並 JOIN magic_altar、magic_forest 得到 location_text
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string query = @"
                SELECT 
                    s.scroll_id,
                    s.word,
                    s.pronunciation,
                    s.part_of_speech,
                    s.meaning,
                    s.example_sentence,
                    s.example_translation,
                    s.past_tense,
                    s.past_participle,
                    s.word_audio_url,
                    s.synonym_words,
                    s.antonym_words,
                    s.related_info,
                    CASE 
                        WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 
                    END AS is_favorite,
                    mf.forest_name_zh + N' 祭壇' + CAST(ma.altar_id AS NVARCHAR) AS location_text
                FROM ancient_scrolls s
                LEFT JOIN user_favorite_words f
                    ON s.scroll_id = f.scroll_id AND f.user_id = @UserID
                JOIN magic_altar ma ON s.altar_id = ma.altar_id
                JOIN magic_forest mf ON ma.forest_id = mf.forest_id
                WHERE s.altar_id = @AltarID AND s.priority_level = 1
            ";
            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@AltarID", altarId);
            cmd.Parameters.AddWithValue("@UserID", (int)HttpContext.Current.Session["UserID"]);

            SqlDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                results.Add(new
                {
                    scroll_id = (int)reader["scroll_id"],
                    word = reader["word"].ToString(),
                    pronunciation = reader["pronunciation"].ToString(),
                    part_of_speech = reader["part_of_speech"].ToString(),
                    meaning = reader["meaning"].ToString(),
                    example_sentence = reader["example_sentence"].ToString(),
                    example_translation = reader["example_translation"].ToString(),
                    past_tense = reader["past_tense"].ToString(),
                    past_participle = reader["past_participle"].ToString(),
                    word_audio_url = reader["word_audio_url"]?.ToString(),
                    synonym_words = reader["synonym_words"]?.ToString(),
                    antonym_words = reader["antonym_words"]?.ToString(),
                    related_info = reader["related_info"]?.ToString(),
                    is_favorite = Convert.ToBoolean(reader["is_favorite"]),
                    location_text = reader["location_text"].ToString()
                });
            }
        }

        // 3. C# 端進行亂數洗牌（Fisher-Yates Shuffle）
        var rng = new Random();
        int n = results.Count;
        while (n > 1)
        {
            n--;
            int k = rng.Next(n + 1);
            var value = results[k];
            results[k] = results[n];
            results[n] = value;
        }

        // 4. 回傳隨機順序的全部單字資料
        return results;
    }
}
