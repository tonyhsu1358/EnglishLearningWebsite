﻿using Microsoft.Owin.Security;
using Microsoft.AspNet.Identity;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using EnglishLearningWebsite;

public partial class OpenAuthProviders : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack)
        {
            var provider = Request.Form["provider"];
            if (provider == null)
            {
                return;
            }
            // 要求重新導向至外部登入提供者
            string redirectUrl = ResolveUrl(String.Format(CultureInfo.InvariantCulture, "~/Account/RegisterExternalLogin?{0}={1}&returnUrl={2}", IdentityHelper.ProviderNameKey, provider, ReturnUrl));
            var properties = new AuthenticationProperties() { RedirectUri = redirectUrl };
            // 連線帳戶時新增 xsrf 驗證
            if (Context.User.Identity.IsAuthenticated)
            {
                properties.Dictionary[IdentityHelper.XsrfKey] = Context.User.Identity.GetUserId();
            }
            Context.GetOwinContext().Authentication.Challenge(properties, provider);
            Response.StatusCode = 401;
            Response.End();
        }
    }

    public string ReturnUrl { get; set; }

    public IEnumerable<string> GetProviderNames()
    {
        return Context.GetOwinContext().Authentication.GetExternalAuthenticationTypes().Select(t => t.AuthenticationType);
    }
}