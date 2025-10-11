using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 允許 AJAX 呼叫
public class DiamondStoreService : WebService
{
    private readonly string connectionString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

    // ✅ 實際 Session 驗證
    private bool IsUserLoggedIn()
    {
        return HttpContext.Current != null &&
               HttpContext.Current.Session != null &&
               HttpContext.Current.Session["UserID"] != null;
    }

    // ✅ 撈出所有上架商品與規格
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string GetActiveProducts()
    {
        var serializer = new JavaScriptSerializer();

        if (!IsUserLoggedIn())
        {
            return serializer.Serialize(new { success = false, message = "使用者尚未登入。" });
        }

        int userId = (int)HttpContext.Current.Session["UserID"]; // ✅ 實際取得使用者 ID
        var productList = new List<object>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string query = @"
                    SELECT 
                        p.product_id,
                        p.product_name,
                        p.product_description,
                        p.main_image,
                        v.variant_id,
                        v.spec_name,
                        v.price,
                        v.spec_image,
                        v.stock
                    FROM ShopProducts AS p
                    INNER JOIN ShopProductVariants AS v
                        ON p.product_id = v.product_id
                    WHERE p.is_active = 1 AND v.is_active = 1
                    ORDER BY p.product_id, v.variant_id;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        productList.Add(new
                        {
                            product_id = Convert.ToInt32(r["product_id"]),
                            name = r["product_name"].ToString(),
                            description = r["product_description"].ToString(),
                            main_image = r["main_image"].ToString(),
                            variant_id = Convert.ToInt32(r["variant_id"]),
                            spec_name = r["spec_name"].ToString(),
                            price = Convert.ToInt32(r["price"]),
                            spec_image = r["spec_image"].ToString(),
                            stock = Convert.ToInt32(r["stock"])
                        });
                    }
                }
            }

            return serializer.Serialize(new { success = true, userId = userId, data = productList });
        }
        catch (Exception ex)
        {
            return serializer.Serialize(new { success = false, message = "伺服器發生錯誤：" + ex.Message });
        }
    }

    // ✅ 寫入使用者訂單紀錄
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string CreateRedemptionRecord(string variant_id, string quantity, string name, string phone, string address, string remark)
    {
        var serializer = new JavaScriptSerializer();

        if (!IsUserLoggedIn())
        {
            Debug.WriteLine("❌ [CreateRedemptionRecord] User not logged in.");
            return serializer.Serialize(new { success = false, message = "使用者尚未登入。" });
        }

        // 🔐 讀取 Session
        int userId = (int)HttpContext.Current.Session["UserID"];
        string userEmail = Convert.ToString(HttpContext.Current.Session["UserEmail"]) ?? "unknown";

        // 🧼 安全解析參數（把逗號/空白都清掉再轉 int）
        try
        {
            variant_id = Regex.Replace(variant_id ?? "", @"[^\d]", "");
            quantity = Regex.Replace(quantity ?? "", @"[^\d]", "");

            if (!int.TryParse(variant_id, out int _vid))
                return serializer.Serialize(new { success = false, message = "參數錯誤：variant_id" });

            if (!int.TryParse(quantity, out int _qty) || _qty <= 0)
                return serializer.Serialize(new { success = false, message = "參數錯誤：quantity" });

            int vid = _vid;
            int qty = _qty;

            Debug.WriteLine($"➡️ [CreateRedemptionRecord] uid={userId}, email={userEmail}, vid={vid}, qty={qty}");

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                Debug.WriteLine("✅ [DB] Connection opened.");

                // 1) 取單價
                int pricePerItem = 0;
                try
                {
                    const string sqlPrice = "SELECT price FROM ShopProductVariants WHERE variant_id = @vid";
                    using (SqlCommand cmd = new SqlCommand(sqlPrice, conn))
                    {
                        cmd.Parameters.AddWithValue("@vid", vid);
                        object scalar = cmd.ExecuteScalar();
                        pricePerItem = Convert.ToInt32(scalar == DBNull.Value ? 0 : scalar);
                    }
                    Debug.WriteLine($"ℹ️ [DB] pricePerItem={pricePerItem}");
                    if (pricePerItem <= 0)
                        return serializer.Serialize(new { success = false, message = "查無該規格或價格為 0。" });
                }
                catch (Exception ePrice)
                {
                    Debug.WriteLine("❌ [DB] Get price failed: " + ePrice.Message);
                    throw; // 外層 catch 會抓
                }

                int totalCost = pricePerItem * qty;
                Debug.WriteLine($"ℹ️ [Calc] totalCost={totalCost}");

                // 2) 查鑽石
                int currentDiamond = 0;
                try
                {
                    const string sqlDiamond = "SELECT diamonds_total FROM UserResources WHERE user_id = @uid";
                    using (SqlCommand cmd = new SqlCommand(sqlDiamond, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        object scalar = cmd.ExecuteScalar();
                        currentDiamond = Convert.ToInt32(scalar == DBNull.Value ? 0 : scalar);
                    }
                    Debug.WriteLine($"ℹ️ [DB] currentDiamond={currentDiamond}");
                }
                catch (Exception eDia)
                {
                    Debug.WriteLine("❌ [DB] Get diamonds failed: " + eDia.Message);
                    throw;
                }

                if (currentDiamond < totalCost)
                    return serializer.Serialize(new { success = false, message = "鑽石數量不足。" });

                // 3) 交易：寫訂單 + 扣鑽石
                using (SqlTransaction tran = conn.BeginTransaction())
                {
                    try
                    {
                        // 3-1 寫入訂單
                        int rowsOrder;
                        const string insertOrder = @"
INSERT INTO UserRedemptionRecords
(user_id, user_email, variant_id, quantity, diamonds_spent, shipping_address, contact_phone, remarks)
VALUES
(@uid, @uemail, @vid, @qty, @spent, @addr, @phone, @remark);";

                        using (SqlCommand cmd = new SqlCommand(insertOrder, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@uemail", userEmail);
                            cmd.Parameters.AddWithValue("@vid", vid);
                            cmd.Parameters.AddWithValue("@qty", qty);
                            cmd.Parameters.AddWithValue("@spent", totalCost);
                            cmd.Parameters.AddWithValue("@addr", string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address);
                            cmd.Parameters.AddWithValue("@phone", string.IsNullOrWhiteSpace(phone) ? (object)DBNull.Value : phone);
                            cmd.Parameters.AddWithValue("@remark", string.IsNullOrWhiteSpace(remark) ? (object)DBNull.Value : remark);
                            rowsOrder = cmd.ExecuteNonQuery();
                        }
                        Debug.WriteLine($"✅ [DB] Insert order rows={rowsOrder}");
                        if (rowsOrder <= 0) throw new Exception("Insert order affected 0 rows.");

                        // 3-2 扣鑽石（最終修正版）
                        int rowsRes;
                        const string updateDiamond = @"
-- 💎 第一步：累積花費與操作紀錄
UPDATE UserResources
SET 
    diamonds_spent = diamonds_spent + @spent,
    last_deduction_reason = N'DiamondStore_Redeem',
    last_deduction_time   = GETDATE()
WHERE user_id = @uid;

-- 💎 第二步：重新計算總鑽石
UPDATE UserResources
SET 
    diamonds_total = 
        (diamonds_ai_test + diamonds_vocabulary_game +
         diamonds_listening_test + diamonds_matching_game) - diamonds_spent
WHERE user_id = @uid;

-- 💎 第三步：同步主欄位 diamonds 與總數一致
UPDATE UserResources
SET diamonds = diamonds_total
WHERE user_id = @uid;
";
                        using (SqlCommand cmd = new SqlCommand(updateDiamond, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@spent", totalCost);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            rowsRes = cmd.ExecuteNonQuery();
                        }
                        Debug.WriteLine($"✅ [DB] Update resources rows={rowsRes}");
                        if (rowsRes <= 0) throw new Exception("Update resources affected 0 rows.");

                        tran.Commit();
                        Debug.WriteLine("🎉 [TX] Commit OK");

                        int newDiamond = currentDiamond - totalCost;
                        return serializer.Serialize(new
                        {
                            success = true,
                            message = "兌換成功！",
                            newDiamonds = newDiamond
                        });
                    }
                    catch (Exception ex2)
                    {
                        Debug.WriteLine("❌ Transaction Exception: " + ex2.ToString());
                        try { tran.Rollback(); Debug.WriteLine("↩️ [TX] Rollback done"); } catch { }
                        return serializer.Serialize(new { success = false, message = "交易失敗，請稍後再試。" });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("❌ Server Exception: " + ex.ToString());
            return serializer.Serialize(new { success = false, message = "伺服器錯誤，請稍後再試。" });
        }
    }

    // =============================================
    // 📦 取得使用者的兌換訂單紀錄
    // =============================================
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string GetUserOrders()
    {
        var serializer = new JavaScriptSerializer();

        // ✅ 驗證使用者登入狀態
        if (HttpContext.Current == null ||
            HttpContext.Current.Session == null ||
            HttpContext.Current.Session["UserID"] == null)
        {
            return serializer.Serialize(new { success = false, message = "使用者尚未登入。" });
        }

        int userId = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
        var orderList = new List<object>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string query = @"
                SELECT 
                    r.redemption_id,
                    r.variant_id,
                    v.spec_name,
                    v.spec_image,
                    v.price,
                    r.quantity,
                    r.diamonds_spent,
                    r.order_status,
                    r.shipping_address,
                    r.contact_phone,
                    r.redeemed_at,
                    r.completed_at,
                    r.remarks
                FROM UserRedemptionRecords AS r
                INNER JOIN ShopProductVariants AS v
                    ON r.variant_id = v.variant_id
                WHERE r.user_id = @user_id
                ORDER BY r.redeemed_at DESC;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@user_id", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            orderList.Add(new
                            {
                                redemption_id = reader["redemption_id"],
                                spec_name = reader["spec_name"].ToString(),
                                spec_image = reader["spec_image"].ToString(),
                                price = Convert.ToInt32(reader["price"]),
                                quantity = Convert.ToInt32(reader["quantity"]),
                                total_spent = Convert.ToInt32(reader["diamonds_spent"]),
                                order_status = reader["order_status"].ToString(),
                                shipping_address = reader["shipping_address"].ToString(),
                                contact_phone = reader["contact_phone"].ToString(),
                                redeemed_at = Convert.ToDateTime(reader["redeemed_at"]).ToString("yyyy/MM/dd HH:mm"),
                                completed_at = reader["completed_at"] == DBNull.Value ? "" : Convert.ToDateTime(reader["completed_at"]).ToString("yyyy/MM/dd HH:mm"),
                                remarks = reader["remarks"].ToString()
                            });
                        }
                    }
                }
            }

            return serializer.Serialize(new
            {
                success = true,
                count = orderList.Count,
                data = orderList
            });
        }
        catch (Exception ex)
        {
            return serializer.Serialize(new { success = false, message = "伺服器錯誤：" + ex.Message });
        }
    }

}
