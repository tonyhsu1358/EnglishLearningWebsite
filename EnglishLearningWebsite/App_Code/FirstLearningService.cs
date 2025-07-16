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
    public object GetFirstLearningWords(int altarId)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { error = "NOT_LOGGED_IN" };

        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        var results = new List<object>();

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            // 抓出該祭壇下所有單字（不重複單字，詞性優先1最前）
            string wordListQuery = @"
            SELECT word
            FROM ancient_scrolls
            WHERE altar_id = @AltarID
            GROUP BY word
            ORDER BY MIN(priority_level) ASC, MIN(scroll_id) ASC";
            SqlCommand wordListCmd = new SqlCommand(wordListQuery, conn);
            wordListCmd.Parameters.AddWithValue("@AltarID", altarId);

            var wordList = new List<string>();
            using (var reader = wordListCmd.ExecuteReader())
                while (reader.Read()) wordList.Add(reader["word"].ToString());

            // 取出每個單字下所有詞性，依 priority_level ASC
            foreach (var word in wordList)
            {
                string detailQuery = @"
                SELECT 
                    s.scroll_id, s.pronunciation, s.part_of_speech, s.meaning,
                    s.example_sentence, s.example_translation, s.past_tense, s.past_participle,
                    s.word_audio_url, s.synonym_words, s.antonym_words, s.related_info,
                    s.priority_level,
                    CASE WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
                    mf.forest_name_zh + N' 祭壇' + CAST(ma.altar_id AS NVARCHAR) AS location_text
                FROM ancient_scrolls s
                LEFT JOIN user_favorite_words f ON s.scroll_id = f.scroll_id AND f.user_id = @UserID
                JOIN magic_altar ma ON s.altar_id = ma.altar_id
                JOIN magic_forest mf ON ma.forest_id = mf.forest_id
                WHERE s.altar_id = @AltarID AND s.word = @Word
                ORDER BY s.priority_level ASC";
                SqlCommand detailCmd = new SqlCommand(detailQuery, conn);
                detailCmd.Parameters.AddWithValue("@UserID", (int)HttpContext.Current.Session["UserID"]);
                detailCmd.Parameters.AddWithValue("@AltarID", altarId);
                detailCmd.Parameters.AddWithValue("@Word", word);

                var posList = new List<object>();
                string locationText = "";
                using (var dr = detailCmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        posList.Add(new
                        {
                            scroll_id = (int)dr["scroll_id"],
                            pronunciation = dr["pronunciation"]?.ToString(),
                            part_of_speech = dr["part_of_speech"]?.ToString(),
                            meaning = dr["meaning"]?.ToString(),
                            example_sentence = dr["example_sentence"]?.ToString(),
                            example_translation = dr["example_translation"]?.ToString(),
                            past_tense = dr["past_tense"]?.ToString(),
                            past_participle = dr["past_participle"]?.ToString(),
                            word_audio_url = dr["word_audio_url"]?.ToString(),
                            synonym_words = dr["synonym_words"]?.ToString(),
                            antonym_words = dr["antonym_words"]?.ToString(),
                            related_info = dr["related_info"]?.ToString(),
                            priority_level = (int)dr["priority_level"],
                            is_favorite = Convert.ToBoolean(dr["is_favorite"])
                        });
                        locationText = dr["location_text"]?.ToString();
                    }
                }
                if (posList.Count > 0)
                    results.Add(new
                    {
                        word = word,
                        location_text = locationText,
                        positions = posList
                    });
            }
        }

        // Fisher-Yates 洗牌（如須亂序）
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
        return results;
    }
}
