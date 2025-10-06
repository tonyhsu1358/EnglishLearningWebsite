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
public class MatchingGameService : WebService
{
    public MatchingGameService() { }

    // ✅ 撈取指定難度的隨機單字（10筆）
    [WebMethod(EnableSession = true)]
    public object GetMatchingWords(string difficulty)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN", message = "使用者尚未登入。" };

        int userId = (int)HttpContext.Current.Session["UserID"];

        int minForest, maxForest;
        switch (difficulty)
        {
            case "初級": minForest = 1; maxForest = 2; break;
            case "中級": minForest = 3; maxForest = 4; break;
            case "中高級": minForest = 5; maxForest = 7; break;
            default:
                return new { status = "INVALID_DIFFICULTY", message = "難度參數錯誤。" };
        }

        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        List<object> results = new List<object>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"
SELECT TOP 10 
    s.word,
    LEFT(s.meaning, 
         CASE 
            WHEN CHARINDEX(N'；', s.meaning) > 0 
            THEN CHARINDEX(N'；', s.meaning) - 1 
            ELSE LEN(s.meaning) 
         END
    ) AS first_meaning
FROM ancient_scrolls s
JOIN magic_altar ma ON s.altar_id = ma.altar_id
JOIN magic_forest mf ON ma.forest_id = mf.forest_id
WHERE s.priority_level = 1 
  AND mf.forest_id BETWEEN @MinForest AND @MaxForest
GROUP BY s.word, s.meaning
ORDER BY NEWID();";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MinForest", minForest);
                cmd.Parameters.AddWithValue("@MaxForest", maxForest);

                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    results.Add(new
                    {
                        word = reader["word"].ToString(),
                        meaning = reader["first_meaning"].ToString()
                    });
                }
            }

            return new { status = "OK", count = results.Count, data = results };
        }
        catch (Exception ex)
        {
            return new { status = "SERVER_ERROR", message = ex.Message };
        }
    }

    // =======================================================
    // ✅ 方法二：結算配對挑戰的發鑽 / 扣鑽邏輯（改版）
    // =======================================================
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object UpdateMatchingResult(int betAmount, double rate, double accuracy)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN" };

        int userId = (int)HttpContext.Current.Session["UserID"];
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        double reward = Math.Floor(betAmount * rate);
        bool isWin = accuracy >= 80.0;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            using (SqlTransaction tran = conn.BeginTransaction())
            {
                try
                {
                    string selectSql = @"
                        SELECT diamonds, diamonds_total, diamonds_spent, diamonds_matching_game
                        FROM UserResources WHERE user_id = @UserID";

                    int curDiamonds = 0, curTotal = 0, curSpent = 0, curMatch = 0;

                    using (SqlCommand cmd = new SqlCommand(selectSql, conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                curDiamonds = dr.GetInt32(0);
                                curTotal = dr.GetInt32(1);
                                curSpent = dr.GetInt32(2);
                                curMatch = dr.GetInt32(3);
                            }
                        }
                    }

                    int newDiamonds = curDiamonds - betAmount;
                    int newTotal = curTotal - betAmount;
                    int newSpent = curSpent + betAmount;  // 💎 無論輸贏都加上本金
                    int newMatch = curMatch;
                    string reason = "";

                    if (isWin)
                    {
                        newDiamonds += (int)reward;
                        newTotal += (int)reward;
                        newMatch += (int)reward;
                        reason = "MatchingGame_Win";
                    }
                    else
                    {
                        reason = "MatchingGame_Fail";
                    }

                    if (newDiamonds < 0) newDiamonds = 0;
                    if (newTotal < 0) newTotal = 0;

                    string updateSql = @"
                        UPDATE UserResources
                        SET diamonds = @NewDiamonds,
                            diamonds_total = @NewTotal,
                            diamonds_spent = @NewSpent,
                            diamonds_matching_game = @NewMatch,
                            last_deduction_time = GETDATE(),
                            last_deduction_reason = @Reason
                        WHERE user_id = @UserID";

                    using (SqlCommand cmd = new SqlCommand(updateSql, conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@NewDiamonds", newDiamonds);
                        cmd.Parameters.AddWithValue("@NewTotal", newTotal);
                        cmd.Parameters.AddWithValue("@NewSpent", newSpent);
                        cmd.Parameters.AddWithValue("@NewMatch", newMatch);
                        cmd.Parameters.AddWithValue("@Reason", reason);
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.ExecuteNonQuery();
                    }

                    tran.Commit();
                    return new
                    {
                        status = "OK",
                        isWin,
                        betAmount,
                        reward,
                        newTotal,
                        newDiamonds
                    };
                }
                catch (Exception ex)
                {
                    tran.Rollback();
                    return new { status = "ERROR", message = ex.Message };
                }
            }
        }
    }
}
