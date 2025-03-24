<%@ Application Language="C#" %>
<%@ Import Namespace="EnglishLearningWebsite" %>
<%@ Import Namespace="System.Web.Optimization" %>
<%@ Import Namespace="System.Web.Routing" %>

<script runat="server">

    void Application_Start(object sender, EventArgs e)
    {
        RouteConfig.RegisterRoutes(RouteTable.Routes);
        BundleConfig.RegisterBundles(BundleTable.Bundles);
        System.Diagnostics.Debug.WriteLine($"🌍 [INFO] 應用程式啟動 - {DateTime.Now}");
    }

    void Session_Start(object sender, EventArgs e)
    {
        System.Diagnostics.Debug.WriteLine($"🔵 [INFO] Session 開始 - ID: {Session.SessionID} - {DateTime.Now}");
    }

    void Session_End(object sender, EventArgs e)
    {
        string reason = "未知原因";

        // 檢查是否是 IIS 應用程式回收
        if (HttpRuntime.AppDomainAppId == null)
        {
            reason = "⚠ 應用程式重啟 (IIS 回收、伺服器重啟)";
            System.Diagnostics.Debug.WriteLine($"🔴 [INFO] Session 結束 - ID: {Session.SessionID} - {DateTime.Now}");
        }

        // 檢查是否手動清除 Session
        if (Session["ManualClear"] != null)
        {
            reason = "🛑 Session.Abandon() 被執行，程式碼手動清除";
            System.Diagnostics.Debug.WriteLine($"🔴 [INFO] Session 結束 - ID: {Session.SessionID} - {DateTime.Now}");
        }

        System.Diagnostics.Debug.WriteLine($"🔴 [INFO] Session 結束 - ID: {Session.SessionID} - {DateTime.Now} - 原因: {reason}");
    }

</script>
